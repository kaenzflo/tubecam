require_relative '../functions/coordinates'
class MapsController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:index]

  def index
    # TODO: Has to be replaced
    path_to_file = File.join(Rails.root, 'app', 'assets', 'javascripts', 'maps', 'mapstyle.json')
    map_style_file = File.read(path_to_file)
    @mapstyle = map_style_file;

    @tubecamjson = generate_tubecams_json()

    render 'maps/map'
  end


  private

  def generate_tubecams_json()
    @tubecams = TubecamDevice.where(:active => true)

    tubecamsHash = {}
    tubecamsHash[:type] = "FeatureCollection"

    tubecamArray = []
    @tubecams.each do |tubecam|
      last_image = Medium.where(:tubecam_device_id => tubecam.id).order("id DESC").first;
      if !last_image.nil?
        longitude = Coordinates.wgsToCHy(last_image.longitude,last_image.latitude);
        latitude = Coordinates.wgsToCHx(last_image.longitude,last_image.latitude);
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

  def generate_description serialnumber, status, longitude, latitude, tubecam, description
    s = StringIO.new
    s << "Seriennummer: " + serialnumber
    s << "<br />"
    s << "Koordinaten: " + longitude.to_s + ", " + latitude.to_s
    s << "<br />"
    s << "Beschreibung: <br />" + description
    s << "<br />"
    s << "<hr class='hr-popover'>"
    s << "<a href='" + tubecam_device_url(tubecam) + "'>Tubecamdetails</a>"
    s << " | "
    s << "<a href='" + media_path + "?tubecam_device_id=" + tubecam.id.to_s + "'>Fotos</a>"

    s.string
  end
end