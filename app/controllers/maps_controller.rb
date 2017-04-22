class MapsController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:index]

  def index

    path_to_file = File.join(Rails.root, 'app', 'assets', 'javascripts', 'maps', 'mapgeo.json')
    map_geo_file = File.read(path_to_file)
    @mapgeo = map_geo_file;

    path_to_file = File.join(Rails.root, 'app', 'assets', 'javascripts', 'maps', 'mapstyle.json')
    map_style_file = File.read(path_to_file)
    @mapstyle = map_style_file;



    render template: "maps/map"
  end
end