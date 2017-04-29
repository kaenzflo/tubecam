class TubecamDevicesController < ApplicationController
  before_action :set_tubecam_device, only: [:show, :edit, :update, :destroy]

  skip_before_action :authenticate_user!

  # GET /tubecam_devices
  # GET /tubecam_devices.json
  def index
    @tubecam_devices = TubecamDevice.all
  end

  # GET /tubecam_devices/1
  # GET /tubecam_devices/1.json
  def show
  end

  # GET /tubecam_devices/new
  def new
    @tubecam_device = TubecamDevice.new
  end

  # GET /tubecam_devices/1/edit
  def edit
  end

  # POST /tubecam_devices
  # POST /tubecam_devices.json
  def create
    @tubecam_device = TubecamDevice.new(tubecam_device_params)

    respond_to do |format|
      if @tubecam_device.save
        format.html { redirect_to @tubecam_device, notice: 'Tubecam device was successfully created.' }
        format.json { render :show, status: :created, location: @tubecam_device }
      else
        format.html { render :new }
        format.json { render json: @tubecam_device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tubecam_devices/1
  # PATCH/PUT /tubecam_devices/1.json
  def update
    respond_to do |format|
      if @tubecam_device.update(tubecam_device_params)
        format.html { redirect_to @tubecam_device, notice: 'Tubecam device was successfully updated.' }
        format.json { render :show, status: :ok, location: @tubecam_device }
      else
        format.html { render :edit }
        format.json { render json: @tubecam_device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tubecam_devices/1
  # DELETE /tubecam_devices/1.json
  def destroy
    @tubecam_device.destroy
    respond_to do |format|
      format.html { redirect_to tubecam_devices_url, notice: 'Tubecam device was successfully destroyed.' }
      format.json { head :no_content }
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