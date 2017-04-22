class MapsController < ApplicationController
  def index
    render template: "maps/map"
  end
end