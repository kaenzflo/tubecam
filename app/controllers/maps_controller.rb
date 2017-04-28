class MapsController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:index]

  def index

    path_to_file = File.join(Rails.root, 'app', 'assets', 'javascripts', 'maps', 'mapstyle.json')
    map_style_file = File.read(path_to_file)
    @mapstyle = map_style_file;


    @mapgeo = generate_tubecams_json()

    render template: "maps/map"
  end


  private

  def generate_tubecams_json()
    @tubecams = TubecamDevice.where(:active => true)

    tubecamsHash = {}
    tubecamsHash[:type] = "FeatureCollection"

    tubecamArray = []
    @tubecams.each do |tubecam|
      last_image = Medium.where(:tubecam_device_id => tubecam.id).order("id DESC").first;
      description = generate_description(tubecam.serialnumber.to_s,"on",last_image.longitude,last_image.latitude, tubecam,tubecam.description)
      if !last_image.nil?
        tubecamHash = {"type" => "Feature",
                       "geometry" => {
                           "type" => "Point",
                           "coordinates" => [last_image.longitude, last_image.latitude]
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
    s << "Links : <a href='" + tubecam_device_url(tubecam) + "'>Show</a>"
    s << "<br />"
    s << "Beschreibung: <br />" + description

    s.string
  end
end