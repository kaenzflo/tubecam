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

    if user_signed_in?
      @poi_json, @poi_style_faked = set_poi()
      render 'maps/map'
    else
      @poi_json_faked, @poi_style_faked = set_poi(exact_position=false)
      flash[:notice] = t('flash.maps.position_not_acurate')
      render 'maps/mapdefault'
    end
  end

  private

  # Permitte parameters
  def map_params
    params.permit(:longitude, :latitude)
  end

  def set_poi(exact_position=true)
    @tubecams = TubecamDevice.where(active: true)

    jsonHash = {}
    jsonHash['type'] = "FeatureCollection"

    styleHash = {}
    styleHash['type'] = "unique"
    styleHash['property'] = "style-class"

    number_of_grouped_sequences = Sequence.where(deleted: false).group(:tubecam_device_id).count
    max_sequences = number_of_grouped_sequences.max_by(&:last)[1]
    min_sequences = number_of_grouped_sequences.min_by(&:last)[1]
    datetime_now = Time.now.to_date;

    jsonArray = []
    styleArray = []
    @tubecams.each do |tubecam|
      if !tubecam.sequences.first.nil?
        number_of_sequences = tubecam.sequences.where(deleted: false).count
        time_period = (datetime_now - tubecam.last_activity.to_date).to_i
        jsonArray << set_poi_json(tubecam, exact_position, number_of_sequences, time_period)
        styleArray << set_poi_style(tubecam, number_of_sequences, max_sequences, min_sequences, time_period)
      end
    end

    jsonHash['features'] = jsonArray
    styleHash['values'] = styleArray

    [jsonHash.to_json, styleHash.to_json]
  end

  def set_poi_json(tubecam, exact_position, number_of_sequences, time_period )

    coordinates = {'longitude' => tubecam.longitude, 'latitude' => tubecam.latitude}
    if !exact_position
      coordinates = Coordinates.fake_coordinates(coordinates['longitude'], coordinates['latitude'])
    end
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
  end

  def set_poi_style(tubecam, number_of_sequences, max_sequences, min_sequences, time_period)
    relative_point_factor = calculate_point_factor(number_of_sequences, max_sequences, min_sequences, 3)

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
  end


  def generate_description (tubecam, exact_position, time_period, coordinates, number_of_sequences)
    s = StringIO.new
    s << "<p>#{I18n.t 'controllers.maps.popup.serialnumber'}:<b> #{tubecam.serialnumber.to_s}</b></p>"
    s << "<p>#{I18n.t 'controllers.maps.popup.number_of_sequences'}: <b>#{number_of_sequences.to_s}</b></p>"
    s << "<p>#{I18n.t 'controllers.maps.popup.last_activity'}: #{tubecam.last_activity.to_time.strftime('%d.%m.%Y').to_s} (#{(I18n.t 'controllers.maps.popup.days', count: time_period)})</p>"
    if exact_position
      s << "<p>#{I18n.t 'controllers.maps.popup.coordiantes'} (#{tubecam.geodetic_datum}):<br>#{sprintf('%#.2f', coordinates['longitude'])}, #{sprintf('%#.2f', coordinates['latitude'])}</p>"
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

  def calculate_point_factor(number_of_sequences, max_sequences, min_sequences, scalefactor)
    relative = 1.0 * min_sequences / max_sequences * (number_of_sequences * scalefactor) + 1
    relative
  end

  # Calculates geometrical center of all tubecams
  def calculate_best_default_view_options
    sequences = Sequence.where(deleted: false)
    long_sum = 0
    sequences.pluck(:longitude).each do |long|
      long_sum += long
    end
    long_cent = long_sum / sequences.size

    lat_sum = 0
    sequences.pluck(:latitude).each do |lat|
      lat_sum += lat
    end
    lat_cent = lat_sum / sequences.size

    [long_cent, lat_cent]
  end

end