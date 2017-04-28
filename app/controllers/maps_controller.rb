class MapsController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:index]

  def index

    path_to_file = File.join(Rails.root, 'app', 'assets', 'javascripts', 'maps', 'mapstyle.json')
    map_style_file = File.read(path_to_file)
    @mapstyle = map_style_file;


    @tubecams = TubecamDevice.where(:active => true)

    tubecamsHash = {}
    tubecamsHash[:type] = "FeatureCollection"
    tubecamsHash[:features] = generate_tubecams_array()
    @mapgeo = tubecamsHash.to_json

    render template: "maps/map"
  end


  private

  def generate_tubecams_array()
    tubecamArray = []
    @tubecams.each do |tubecam|
      last_image = Medium.where(:tubecam_device_id => tubecam.id).order("id DESC").first;
      description = generate_description(tubecam.serialnumber.to_s, "on", last_image.longitude, last_image.latitude, "beschreibung")
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

    tubecamArray
  end

  def generate_description serialnumber, status, longitude, latitude, description
    s = StringIO.new
    s << "Seriennummer: " + serialnumber
    s << "<br />"
    s << "Koordinaten: " + longitude.to_s + ", " + latitude.to_s
    s << "<br />"
    s << "Links : "
    s << "<br />"
    s << "Beschreibung: " + description

    s.string
  end
end