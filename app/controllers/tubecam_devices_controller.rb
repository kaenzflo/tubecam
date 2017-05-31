##
# Holds tubecams and provides CRUD functions. A specific
# tubecam can also be activated or deactivated.
##
class TubecamDevicesController < ApplicationController
  before_action :set_tubecam_device, only: %i[show edit update destroy]

  load_and_authorize_resource
  skip_before_filter :authenticate_user!
  skip_authorize_resource only: :show

  # Lists all tubecam_devices
  def index
    @tubecam_devices = TubecamDevice.all.order(:id)
    if user_signed_in? &&
       !current_user.admin_role? &&
       current_user.trapper_role?
      @tubecam_devices = @tubecam_devices.where(user_id: current_user.id)
    end

  end

  # Shows a specific tubecam_device (as admin a tubecam_device is
  # also shown even if the deleted attribute is set)
  def show
    @sequences = Sequence.where(tubecam_device_id: @tubecam_device.id)
                         .order(datetime: 'DESC').page(params[:page])
    if user_signed_in? && !current_user.admin_role?
      @sequences = @sequences.where(deleted: false)
    end
    @thumbnail_url = "https://#{ENV['S3_HOST_NAME']}/#{ENV['S3_BUCKET_NAME']}/thumbnails/"
  end

  # New tubecam_device
  def new
    @tubecam_device = TubecamDevice.new
    @users = User.all.order(username: 'ASC')
  end

  # Edits tubecam_device
  def edit
    @users = User.all.order(username: 'ASC')
  end

  # Saves tubecam_device to database
  def create
    @tubecam_device = TubecamDevice.new(tubecam_device_params)
    if @tubecam_device.save
      redirect_to action: 'index', notice: t('flash.tubecam_devices.create_success')
    else
      render :new
    end
  end

  # Updates tubecam_device in database
  def update
    if @tubecam_device.update(tubecam_device_params)
      redirect_to action: 'index', notice: t('flash.tubecam_devices.update_success')
    else
      render :edit
    end
  end

  # Destroys tubecam_device
  def destroy
    @tubecam_device.destroy
    redirect_to tubecam_devices_url, notice: t('flash.tubecam_devices.destroy_success')
  end

  # Sets tubecam inactive
  def deactivate
    @tubecam_device = set_tubecam_device
    if current_user.admin_role? && @tubecam_device.update(:active => false)
      redirect_to tubecam_devices_path, notice: t('flash.tubecam_devices.deactivate_success')
    else
      redirect_to tubecam_devices_path, alert: t('flash.tubecam_devices.deactivate_fail')
    end
  end

  # Sets tubecam active
  def activate
    @tubecam_device = set_tubecam_device
    if current_user.admin_role? && @tubecam_device.update(:active => true)
      redirect_to tubecam_devices_path, notice: t('flash.tubecam_devices.activate_success')
    else
      redirect_to tubecam_devices_path, alert: t('flash.tubecam_devices.activate_fail')
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tubecam_device
    @tubecam_device = TubecamDevice.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tubecam_device_params
    params.require(:tubecam_device).permit(:serialnumber, :user_id, :description, :active)
  end

end