require_relative '../functions/coordinates'

class MapsController < ApplicationController

  skip_before_action :authenticate_user!, :only => [:index]

  def index
    @tubecamjson = generate_tubecams_json()
    @tubecamjson_approximated = generate_tubecams_json(exact_position=false)

    @tubecamstyle = generate_tubecams_style()

    if user_signed_in?
      render 'maps/map'
    else
      render 'maps/mapdefault'
    end
  end

  private

  def generate_tubecams_json(exact_position=false)
    @tubecams = TubecamDevice.where(:active => true)

    tubecamsHash = {}
    tubecamsHash[:type] = "FeatureCollection"

    tubecamArray = []
    @tubecams.each do |tubecam|
      latest_image = Medium.where(:tubecam_device_id => tubecam.id).order("id DESC").first;
      if !latest_image.nil?
        longitude = Coordinates.wgsToCHy(latest_image.longitude,latest_image.latitude);
        latitude = Coordinates.wgsToCHx(latest_image.longitude,latest_image.latitude);
        time_period = days_since_last_image(latest_image)
        latest_image_text = latest_image_text(latest_image, time_period)
        if !exact_position
          longitude = approximate_coordinates longitude
          latitude = approximate_coordinates latitude
        end
        description = generate_description(tubecam.serialnumber.to_s, latest_image_text, time_period, longitude, latitude, tubecam,tubecam.description, exact_position)

        tubecamHash = {"type" => "Feature",
                       "geometry" => {
                           "type" => "Point",
                           "coordinates" => [longitude, latitude]
                       },
                       "properties" => {
                           "description" => description.to_s,
                           "style-class" => tubecam.id
                       }
        }
        tubecamArray << tubecamHash
      end
    end

    tubecamsHash[:features] = tubecamArray
    tubecamsHash.to_json
  end

  def generate_tubecams_style
    stylesHash = {}
    stylesHash[:type] = "unique"
    stylesHash[:property] = "style-class"

    styleArray = []
    @tubecams.each do |tubecam|
      latest_image = Medium.where(:tubecam_device_id => tubecam.id).order("id DESC").first;
      if !latest_image.nil?
        time_period = days_since_last_image(latest_image)
        point_color = set_point_color(time_period)

        styleHash = {"geomType" => "point",
                      "value" => tubecam.id,
                      "vectorOptions" => {
                          "type" => "circle",
                          "radius" => 10,
                          "fill" => {
                              "color" => point_color,
                              "opacity" => 0.5
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
    stylesHash.to_json
  end

  def generate_description serialnumber, latest_image_text, time_period, longitude, latitude, tubecam, description, exact_position=true
    description = truncate description
    status = time_period < 100 ? '(aktiv)' : '(inaktiv)'
    s = StringIO.new
    s << "<p>" + "Seriennummer:<b> " +serialnumber + "</b> " + status + "</p>"
    s << latest_image_text
    if exact_position
      s << "<p>" + "Koordinaten: " + sprintf('%#.2f', longitude) + ", " + sprintf('%#.2f', latitude) +  "</p>"
    end
    s << "<p>" + "Beschreibung: <br />" + description + "</p>"
    s << "<hr class='hr-popover'>"
    s << "<p>"
    s << "<a href='" + tubecam_device_url(tubecam) + "'>Tubecam</a>"
    s << " | "
    s << "<a href='" + media_path + "?tubecam_device_id=" + tubecam.id.to_s + "'>Fotos</a>"
    s << "</p>"

    s.string
  end

  def truncate s, length = 30, ellipsis = '...'
    if s.length > length
      s.to_s[0..length].gsub(/[^\w]\w+\s*$/, ellipsis)
    else
      s
    end
  end

  def approximate_coordinates value
    #value = (value / 10000).round(1) * 10000 - 100 + Random.rand(200)
    value = value - 20 + Random.rand(40)
  end

  def days_since_last_image(latest_image)
    time_period = (DateTime.now.to_date - latest_image.datetime.to_date).to_i
  end

  def set_point_color(time_period)
    tubecam_active = time_period < 100 ? true : false
    point_color = ''
    if tubecam_active
      point_color = '#FF3300'
    else
      point_color = '#FFAA00'
    end
    point_color
  end

  def latest_image_text(latest_image, time_period)
    day_text = time_period == 1 ? " Tag" : " Tage"
    text = "<p>Letzte Aufnahme: " + latest_image.datetime.to_date.strftime('%d.%m.%Y').to_s + " (" + time_period.to_s + day_text + ")</p>"
  end


end