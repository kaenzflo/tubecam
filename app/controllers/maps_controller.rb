require_relative '../functions/coordinates'
##
# Handles map requests, generates and adds points of interest (POI)
##
class MapsController < ApplicationController

  skip_before_action :authenticate_user!, only: [:index]

  # Shows a map with the tubecam_devices as POI
  def index
    long = map_params[:longitude]
    lat = map_params[:latitude]

    if Sequence.first.nil?
      long = 659_000.00
      lat = 185_548.39
    else
      if long.nil? || lat.nil?
        @longitude, @latitude = calculate_best_default_view_options
        @zoom = 250
      else
        @longitude = long
        @latitude = lat
        @zoom = 10
      end
    end

    if user_signed_in?
      @poi_json, @poi_style_faked = create_poi()
      render 'maps/map'
    else
      @poi_json_faked, @poi_style_faked = create_poi(exact_position = false)
      flash[:notice] = t('flash.maps.position_not_acurate')
      render 'maps/mapdefault'
    end
  end

  private

  # Permitted parameters
  def map_params
    params.permit(:longitude, :latitude)
  end

  # Creates a Point of Interest (POI)
  def create_poi(exact_position = true)
    @tubecams = TubecamDevice.where(active: true)

    json_hash = {}
    json_hash['type'] = 'FeatureCollection'

    style_hash = {}
    style_hash['type'] = 'unique'
    style_hash['property'] = 'style-class'

    number_of_grouped_sequences = Sequence.where(deleted: false)
                                          .group(:tubecam_device_id).count
    max_sequences = number_of_grouped_sequences.max_by(&:last)[1]
    min_sequences = number_of_grouped_sequences.min_by(&:last)[1]
    datetime_now = Time.now.to_date

    json_array = []
    style_array = []
    @tubecams.each do |tubecam|
      next unless tubecam.sequences.first
      number_of_sequences = tubecam.sequences.where(deleted: false).count
      time_period = (datetime_now - tubecam.last_activity.to_date).to_i
      json_array << generates_poi_json(tubecam, exact_position,
                                       number_of_sequences, time_period)
      style_array << generate_poi_style(tubecam, number_of_sequences,
                                        max_sequences, min_sequences, time_period)
    end

    json_hash['features'] = json_array
    style_hash['values'] = style_array

    [json_hash.to_json, style_hash.to_json]
  end

  # Generates JSON formatted POI information for GeoAdmin API map layer
  def generates_poi_json(tubecam, exact_position, number_of_sequences, time_period)
    coordinates = { 'longitude' => tubecam.longitude,
                    'latitude' => tubecam.latitude }
    unless exact_position
      coordinates = Coordinates.fake_coordinates(coordinates['longitude'],
                                                 coordinates['latitude'])
    end
    description = generate_description(tubecam, exact_position,
                                       time_period, coordinates,
                                       number_of_sequences)

    tubecam_hash = { type: 'Feature',
                     geometry: {
                       type: 'Point',
                       coordinates: [coordinates['longitude'],
                                         coordinates['latitude']]
                     },
                     properties: {
                       description: description,
                       'style-class' => tubecam.id
                     }
                   }
  end

  # Generates JSON formatted POI style information for GeoAdmin API map layer
  def generate_poi_style(tubecam, number_of_sequences, max_sequences,
                         min_sequences, time_period)
    relative_point_factor = calculate_point_factor(number_of_sequences,
                                                   max_sequences,
                                                   min_sequences,
                                                   3)

    style_hash = { geomType: 'point',
                   value: tubecam.id,
                   vectorOptions: {
                     type: 'circle',
                     radius: 8 * relative_point_factor,
                     fill: {
                       color: "##{Gradient.green_to_red_by_value(time_period)}"
                     },
                     stroke: {
                       color: '#FFFFFF',
                       width: 2
                     }
                   }
                 }
  end

  # Generates HTML formatted POI description for GeoAdmin API map layer
  def generate_description(tubecam, exact_position, time_period,
                           coordinates, number_of_sequences)
    s = StringIO.new
    s << "<p>#{I18n.t 'controllers.maps.popup.serialnumber'}:<b> #{tubecam.serialnumber.to_s}</b></p>"
    s << "<p>#{I18n.t 'controllers.maps.popup.number_of_sequences'}: <b>#{number_of_sequences.to_s}</b></p>"
    s << "<p>#{I18n.t 'controllers.maps.popup.last_activity'}: #{tubecam.last_activity.to_time.strftime('%d.%m.%Y').to_s} (#{(I18n.t 'controllers.maps.popup.days', count: time_period)})</p>"
    if exact_position
      s << "<p>#{I18n.t 'controllers.maps.popup.coordiantes'} (#{tubecam.geodetic_datum}):<br>#{sprintf('%#.2f', coordinates['latitude'])}, #{sprintf('%#.2f', coordinates['latitude'])}</p>"
    end
    s << "<p>#{I18n.t 'controllers.maps.popup.description'}:<br>#{tubecam.description}</p>"
    s << "<hr class='hr-popover'>"
    s << "<p>#{view_context.link_to (I18n.t 'link_to.tubecam'), tubecam_device_path(tubecam)} | #{view_context.link_to (I18n.t 'link_to.media'), sequences_path(tubecam_device_id: tubecam.id) }</p>".html_safe

    s.string
  end

  def truncate(s, length = 30, ellipsis = '...')
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