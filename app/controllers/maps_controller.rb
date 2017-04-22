class MapsController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:index]

  def index
    render template: "maps/map"
  end
end