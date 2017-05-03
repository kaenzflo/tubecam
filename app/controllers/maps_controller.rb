require_relative '../functions/coordinates'

class MapsController < ApplicationController

  skip_before_action :authenticate_user!, :only => [:index]

  def index
    @tubecamjson = generate_tubecams_json()
    @tubecamjson_approximated = generate_tubecams_json(approximate=true)

    @tubecamstyle = generate_tubecams_style()

    if user_signed_in?
      render 'maps/map'
    else
      render 'maps/mapdefault'
    end
  end

  private

  def generate_tubecams_json(approximate=false)
    @tubecams = TubecamDevice.where(:active => true)

    tubecamsHash = {}
    tubecamsHash[:type] = "FeatureCollection"

    tubecamArray = []
    @tubecams.each do |tubecam|
      latest_image = Medium.where(:tubecam_device_id => tubecam.id).order("id DESC").first;
      if !latest_image.nil?
        longitude = Coordinates.wgsToCHy(latest_image.longitude,latest_image.latitude);
        latitude = Coordinates.wgsToCHx(latest_image.longitude,latest_image.latitude);
        if approximate
          longitude = approximate_coordinates longitude
          latitude = approximate_coordinates latitude
        end
        description = generate_description(tubecam.serialnumber.to_s,"on", longitude, latitude, tubecam,tubecam.description)

        tubecamHash = {"type" => "Feature",
                       "geometry" => {
                           "type" => "Point",
                           "coordinates" => [longitude, latitude]
                       },
                       "properties" => {
                           "description" => description.to_s,
                           "style-class" => 0
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
        point_color = set_point_color(latest_image)

        styleHash = {"geomType" => "point",
                      "value" => 0,
                      "vectorOptions" => {
                          "type" => "circle",
                          "radius" => 10,
                          "fill" => {
                              "color" => point_color
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

  def generate_description serialnumber, status, longitude, latitude, tubecam, description
    description = truncate description
    s = StringIO.new
    s << "<p>" + "Seriennummer: " + serialnumber + "</p>"
    s << "<p>" + "Koordinaten: " + sprintf('%#.2f', longitude) + ", " + sprintf('%#.2f', latitude) +  "</p>"
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
    value = (value / 10000).round(1) * 10000 - 100 + Random.rand(200)
  end

  def set_point_color(latest_image)
    time_period = (DateTime.now.to_date - latest_image.datetime.to_date).to_i
    point_color = ''
    if (time_period < 200)
      point_color = '#45FF00'
    else
      point_color = '#FFAA00'
    end
    point_color
  end

end