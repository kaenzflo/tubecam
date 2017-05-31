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

    @image_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/'
    @thumbnail_url = @image_url + ''

  end

  def page_not_found
    respond_to do |format|
      format.html { render template: 'errors/not_found_error', layout: 'layouts/application', status: 404 }
      format.all  { render nothing: true, status: 404 }
    end
  end

end