require 'securerandom'
##
# Handles the welcome page, starts the setup process if the user table
# is empty.
##
class WelcomeController < ApplicationController

  skip_before_action :authenticate_user!, only: %i[index setup config]

  # Shows the welcome page or starts the setup process
  def index

    if User.find_by(username: 'admin').nil?
      setup_init
    else
      @media = []
      media = Medium.where(deleted: false, sequence_id: Sequence.where(deleted: false))
      unless media.empty?
        for i in 1..6
          @media << media[rand(0...media.size)]
        end
      end

      @image_url = "https://#{ENV['S3_HOST_NAME']}/#{ENV['S3_BUCKET_NAME']}/"
      @thumbnail_url = "#{@image_url}thumbnails/"
    end
  end

  # Creates the admin user if token entered correctly
  def setup
    setup_secret = File.read('./setup_secret.txt')
    if setup_secret.to_s.eql?(setup_params[:token])
      User.create(username: 'admin', email: setup_params[:email],
                  password: setup_params[:password], spotter_role: true,
                  verified_spotter_role: true, trapper_role: true,
                  admin_role: true, active: true,
                  confirmed_at: DateTime.now)
      redirect_to '/welcome/config', notice: t('flash.setup.token_success')
    else
      redirect_to '/', alert: t('flash.setup.token_fail')
    end
  end

  # Initializes the setup process
  def setup_init
    secret = SecureRandom.hex
    p '#################SETUP-SECRET################'
    p secret.to_s
    File.open(File.join('.', 'setup_secret.txt'), 'w') do |f|
      f.write(secret)
    end
    @user = User.new
    render 'welcome/setup'
  end

  # Page not found handling
  def page_not_found
    respond_to do |format|
      format.html { render template: 'errors/not_found_error', layout: 'layouts/application', status: 404 }
      format.all  { render nothing: true, status: 404 }
    end
  end

  private

  # White listing parameters for 'setup'
  def setup_params
    params.permit(:email, :password, :token, :utf8, :authenticity_token, :commit)
  end

end