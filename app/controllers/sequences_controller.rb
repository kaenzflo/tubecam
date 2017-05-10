class SequencesController < ApplicationController
  before_action :set_sequence, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource
  skip_before_filter :authenticate_user!
  skip_authorize_resource :only => [:index, :show]

  # GET /sequences
  # GET /sequences.json
  def index
    scope_params = scope_params()
    @filter_params = scope_params
    sequences = Sequence.filter(scope_params)

    sequences = filter_sequences(sequences)

    @sequences = sequences.page(params[:page])
    @cloud_resource_thumbnail_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/thumbnails/'
    @annotations_lookup_table = AnnotationsLookupTable.all.order('annotation_id')
  end

  # GET /sequences/1
  # GET /sequences/1.json
  def show
    sequence = Sequence.find(params[:id])
    @sequence = sequence
    medium = sequence.media.last
    @medium = Coordinates.wgs_to_ch(medium)
    @cloud_resource_thumbnail_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/thumbnails/'
    @cloud_resource_image_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/'
    @tubecam_device = TubecamDevice.find(sequence.tubecam_device_id)
    @annotations = Annotation.where(sequence_id: sequence.id)
    @annotations_lookup_table = AnnotationsLookupTable.all
  end

  # GET /sequences/new
  def new
    @sequence = Sequence.new
  end

  # GET /sequences/1/edit
  def edit
  end

  # POST /sequences
  # POST /sequences.json
  def create
    @sequence = Sequence.new(sequence_params)

    respond_to do |format|
      if @sequence.save
        format.html { redirect_to @sequence, notice: 'Sequence was successfully created.' }
        format.json { render :show, status: :created, location: @sequence }
      else
        format.html { render :new }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sequences/1
  # PATCH/PUT /sequences/1.json
  def update
    respond_to do |format|
      if @sequence.update(sequence_params)
        format.html { redirect_to @sequence, notice: 'Sequence was successfully updated.' }
        format.json { render :show, status: :ok, location: @sequence }
      else
        format.html { render :edit }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sequences/1
  # DELETE /sequences/1.json
  def destroy
    @sequence.destroy
    respond_to do |format|
      format.html { redirect_to sequences_url, notice: 'Sequence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def delete
    @sequence = set_sequence
    tubecam_device_id = @sequence.tubecam_device_id
    if (current_user.admin_role? || current_user.trapper_role?) && @sequence.update( :deleted => true )
      redirect_to tubecam_device_url(tubecam_device_id), notice: 'Das Sequence wurde erfolgreich entfernt.'
    else
      redirect_to tubecam_device_url(tubecam_device_id), alert: 'Das Sequence kann nicht entfernt werden.'
    end
  end

  # Set sequence active
  def activate
    @sequence = set_sequence
    tubecam_device_id = @sequence.tubecam_device_id
    if (current_user.admin_role? || current_user.trapper_role?) && @sequence.update( :deleted => false )
      redirect_to tubecam_device_url(tubecam_device_id), notice: 'Das Sequenze wurde erfolgreich reaktiviert.'
    else
      redirect_to tubecam_device_url(tubecam_device_id), alert: 'Das Sequenze kann nicht reaktivert werden.'
    end
  end

  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_sequence
    @sequence = Sequence.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def sequence_params
    params.require(:sequence).permit(:path, :filename, :sequencestype, :datetime, :longitude, :latitude, :sequence, :frame, :tubecam_device_id, :exifdata, :deleted)
    # Additional for filtering gallery
    params.require(:sequence).permit(:date_start, :date_end, :lookup_table_id)
  end

  def scope_params
    scope_params = params.slice(:tubecam_device_id, :sequence)
  end

  def filter_sequences sequences
    filter_by_date = ''
    if !params[:date_start].nil? && !params[:date_start].empty?
        @filter_params[:date_start] = string_to_date(params[:date_start], '00:00:00')
        filter_date_start = Medium.select(:sequence_id).where(['datetime >=  ?', @filter_params[:date_start]]).uniq.pluck(:sequence_id)
        sequences = sequences.where(id: filter_date_start) if !filter_date_start.nil?
    end
    if !params[:date_end].nil? && !params[:date_end].empty?
        @filter_params[:date_end] = string_to_date(params[:date_end], '22:59:59')
        filter_date_end = Medium.select(:sequence_id).where(['datetime <=  ?', @filter_params[:date_end]]).uniq.pluck(:sequence_id)
        sequences = sequences.where(id: filter_date_end) if !filter_date_end.nil?
    end
    if !params[:lookup_table_id].nil? && !params[:lookup_table_id].empty?
      @filter_params[:lookup_table_id] = params[:lookup_table_id]
      lookup_table_id = params[:lookup_table_id]
      annotation_id = AnnotationsLookupTable.find(lookup_table_id).annotation_id
      if /000/.match(annotation_id)
        p "nur Bilder ohne Tiere"
      end
      if /[1-9]00/.match(annotation_id)
        p "JJJJJJJJJJJUIUIJIU"
        p annotation_id
      end

    end

    sequences
  end

  # scope :date_start, -> (date_start) { where("datetime > ?", date_start) } if !:date_start.empty?

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
