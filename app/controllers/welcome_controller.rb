class WelcomeController < ApplicationController

  skip_before_action :authenticate_user!, :only => [:index]

  def index
    @media = []
    media = Medium.where(deleted: false)
    if !media.empty?
      for i in 1..6
        @media << media[rand(0...media.size)]
      end
    end

    @cloud_resource_image_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/'
    @cloud_resource_thumbnail_url = @cloud_resource_image_url + ''

  end

end