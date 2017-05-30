require_relative '../functions/coordinates'

class MapsController < ApplicationController

  skip_before_action :authenticate_user!, :only => [:index]

  def index
    long = map_params[:longitude]
    lat = map_params[:latitude]

    if Sequence.first.nil?
      long = 659000.00
      lat = 185548.39
    else
      if (long.nil? || lat.nil?)
        @longitude, @latitude = calculate_best_default_view_options
        @zoom = 250
      else
        @longitude = long
        @latitude = lat
        @zoom = 10
      end
    end

    @tubecamjson = generate_tubecams_json()
    @tubecamjson_approximated = generate_tubecams_json(exact_position=false)

    @tubecamstyle = generate_tubecams_style()

    if user_signed_in?
      render 'maps/map'
    else
      flash[:notice] = t('flash.maps.position_not_acurate')
      render 'maps/mapdefault'
    end
  end

  private

  # Permitte parameters
  def map_params
    params.permit(:longitude, :latitude)
  end

  def generate_tubecams_json(exact_position=true)
    @tubecams = TubecamDevice.where(:active => true)

    tubecamsHash = {}
    tubecamsHash[:type] = "FeatureCollection"

    tubecamArray = []
    @tubecams.each do |tubecam|

      latest_image = Medium.find_by(sequence_id: Sequence.where(tubecam_device_id: tubecam.id).order(datetime: 'ASC').last)
      if !tubecam.sequences.first.nil?
        time_period = (Time.now.to_date - tubecam.last_activity.to_date)

        coordinates = {
            'longitude' => tubecam.longitude,
            'latitude' => tubecam.latitude
        }
        if !exact_position
          coordinates = Coordinates.fake_coordinates(tubecam.longitude, tubecam.latitude)
        end
        number_of_sequences = tubecam.sequences.count
        description = generate_description(tubecam, exact_position, time_period, coordinates, number_of_sequences)

        tubecamHash = {"type" => "Feature",
                       "geometry" => {
                           "type" => "Point",
                           "coordinates" => [coordinates['longitude'], coordinates['latitude']]
                       },
                       "properties" => {
                           "description" => description,
                           "style-class" => tubecam.id
                       }
        }
        tubecamArray << tubecamHash
      end
    end

    tubecamsHash[:features] = tubecamArray
    p "==="
    p tubecamsHash.to_json.inspect
    p "???"
    tubecamsHash.to_json
  end

  def generate_tubecams_style
    total_images = Medium.all.where(deleted: false).count
    amount_of_sequences = Sequence.where(deleted: false).group(:tubecam_device_id).count
    max_sequences = amount_of_sequences.max_by(&:last)[1]
    min_sequences = amount_of_sequences.min_by(&:last)[1]

    stylesHash = {}
    stylesHash[:type] = "unique"
    stylesHash[:property] = "style-class"

    styleArray = []
    @tubecams.each do |tubecam|
      if !tubecam.sequences.first.nil?
         time_period = (Time.now.to_date - tubecam.last_activity.to_date)

         relative_point_factor = calculate_point_factor(tubecam.id, max_sequences, min_sequences, 1)

        styleHash = {"geomType" => "point",
                      "value" => tubecam.id,
                      "vectorOptions" => {
                          "type" => "circle",
                          "radius" => 8 * relative_point_factor,
                          "fill" => {
                              "color" => "##{Gradient.randomColor(time_period)}"
                          },
                          "stroke" => {
                              "color" => "#FFFFFF",
                              "width" => 2
                          }
                      }
        }
        styleArray << styleHash
      end
    end

    stylesHash[:values] = styleArray
    p "==="
    p stylesHash.to_json.inspect
    p "???"
    stylesHash.to_json
  end


  def generate_description (tubecam, exact_position, time_period, coordinates, number_of_sequences)
    s = StringIO.new
    s << "<p>#{I18n.t 'controllers.maps.popup.serialnumber'}:<b> #{tubecam.serialnumber.to_s}</b></p>"
    s << "<p>#{I18n.t 'controllers.maps.popup.number_of_sequences'}: <b>#{number_of_sequences.to_s}</b></p>"
    s << "<p>#{I18n.t 'controllers.maps.popup.last_activity'}: #{tubecam.last_activity.to_time.strftime('%d.%m.%Y').to_s} (#{(I18n.t 'controllers.maps.popup.days', count: time_period)})</p>"
    if exact_position
      s << "<p>#{I18n.t 'controllers.maps.popup.coordiantes'}:<br>#{tubecam.geodetic_datum} #{sprintf('%#.2f', coordinates['longitude'])}, #{sprintf('%#.2f', coordinates['latitude'])}</p>"
    end
    s << "<p>#{I18n.t 'controllers.maps.popup.description'}:<br>#{tubecam.description}</p>"
    s << "<hr class='hr-popover'>"
    s << "<p>#{view_context.link_to (I18n.t 'link_to.tubecam'), tubecam_device_path(tubecam)} | #{view_context.link_to (I18n.t 'link_to.media'), sequences_path(tubecam_device_id: tubecam.id) }</p>".html_safe

    s.string
  end

  def truncate s, length = 30, ellipsis = '...'
    if s.length > length
      s.to_s[0..length].gsub(/[^\w]\w+\s*$/, ellipsis)
    else
      s
    end
  end

  def calculate_point_factor(tubecam_id, max_sequences, min_sequences, scalefactor)
    amount_of_sequences = Sequence.where(tubecam_device_id: tubecam_id, deleted: false).count
    relative = 1.0 * min_sequences / max_sequences * (amount_of_sequences * scalefactor) + 1
    p relative
    relative
  end

  # Calculates geometrical center of all tubecams
  def calculate_best_default_view_options
    long_sum = 0
    Medium.pluck(:longitude).each do |long|
      long_sum += long
    end
    long_cent = long_sum / Medium.all.size

    lat_sum = 0
    Medium.pluck(:latitude).each do |lat|
      lat_sum += lat
    end
    lat_cent = lat_sum / Medium.all.size
    
    [long_cent, lat_cent]
  end

end