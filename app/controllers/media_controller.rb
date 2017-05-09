class MediaController < ApplicationController
  before_action :set_medium, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource
  skip_before_filter :authenticate_user!
  skip_authorize_resource :only => [:index, :show]

  # GET /media
  # GET /media.json
  def index
    @filter_params = filter_params()
    media = Medium.filter(@filter_params)
    @media = media.where(deleted: false).page(params[:page])
    @cloud_resource_thumbnail_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/thumbnails/'
  end

  # GET /media/1
  # GET /media/1.json
  def show
    medium = Medium.find(params[:id])
    @medium = Coordinates.wgs_to_ch(medium)
    @cloud_resource_image_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/'
    @tubecam_device = TubecamDevice.find(medium.tubecam_device_id)
    @annotations = MediumAnnotation.where(medium_id: medium.id)
    @annotations_lookup_table = AnnotationsLookupTable.all
  end

  # GET /media/new
  def new
    @medium = Medium.new
  end

  # GET /media/1/edit
  def edit
  end

  # POST /media
  # POST /media.json
  def create
    @medium = Medium.new(medium_params)

    respond_to do |format|
      if @medium.save
        format.html { redirect_to @medium, notice: 'Medium was successfully created.' }
        format.json { render :show, status: :created, location: @medium }
      else
        format.html { render :new }
        format.json { render json: @medium.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /media/1
  # PATCH/PUT /media/1.json
  def update
    respond_to do |format|
      if @medium.update(medium_params)
        format.html { redirect_to @medium, notice: 'Medium was successfully updated.' }
        format.json { render :show, status: :ok, location: @medium }
      else
        format.html { render :edit }
        format.json { render json: @medium.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /media/1
  # DELETE /media/1.json
  def destroy
    @medium.destroy
    respond_to do |format|
      format.html { redirect_to media_url, notice: 'Medium was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def delete
    @medium = set_medium
    tubecam_device_id = @medium.tubecam_device_id
    if (current_user.admin_role? || current_user.trapper_role?) && @medium.update( :deleted => true )
      redirect_to tubecam_device_url(tubecam_device_id), notice: 'Das Medium wurde erfolgreich entfernt.'
    else
      redirect_to tubecam_device_url(tubecam_device_id), alert: 'Das Medium kann nicht entfernt werden.'
    end
  end

  # Set medium active
  def activate
    @medium = set_medium
    tubecam_device_id = @medium.tubecam_device_id
    if (current_user.admin_role? || current_user.trapper_role?) && @medium.update( :deleted => false )
      redirect_to tubecam_device_url(tubecam_device_id), notice: 'Das Medium wurde erfolgreich reaktiviert.'
    else
      redirect_to tubecam_device_url(tubecam_device_id), alert: 'Das Medium kann nicht reaktivert werden.'
    end
  end

  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_medium
    @medium = Medium.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def medium_params
    params.require(:medium).permit(:path, :filename, :mediatype, :datetime, :longitude, :latitude, :sequence, :frame, :tubecam_device_id, :exifdata, :deleted)
    # Additional for filtering gallery
    params.require(:medium).permit(:date_start, :date_end)
  end

  def filter_params
    filter_params = params.slice(:tubecam_device_id, :sequence, :date_start, :date_end)

    if !filter_params[:date_start].nil?
      filter_params[:date_start] = string_to_date(filter_params[:date_start], '00:00:00')
    end
    if !filter_params[:date_end].nil?
      filter_params[:date_end] = string_to_date(filter_params[:date_end], '22:59:59')
    end

    filter_params
  end

  def string_to_date date_string, time
    if !date_string.empty?
      date_start_string = date_string.split(".")
      date_start_string = date_start_string[2] + ":" + date_start_string[1] + ":" + date_start_string[0] + " " + time
      date_start = DateTime.strptime(date_start_string, '%Y:%m:%d %H:%M:%S')
      date_string = date_start
    end
    date_string
  end


end
