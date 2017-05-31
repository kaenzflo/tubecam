##
# Handles sequence requests, provides CRUD functions.
# Provides possibility to verify an annotation as verified
# spotter
##
class SequencesController < ApplicationController
  before_action :set_sequence, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource
  skip_before_filter :authenticate_user!
  skip_authorize_resource :only => [:index, :show, :verify, :unverify]

  # GET /sequences
  def index
    scope_params = scope_params()
    @filter_params = scope_params
    sequences = Sequence.filter(scope_params)
    sequences = filter_sequences(sequences)
    sequences = sequences.where(deleted: false).order('datetime DESC')
    @sequences = sequences.page(params[:page])
    @thumbnail_url = "https://#{ENV['S3_HOST_NAME']}/#{ENV['S3_BUCKET_NAME']}/thumbnails/"
    @annotations_lookup_table = AnnotationsLookupTable.all
    @annotations = Annotation.all
    @tubecam_devices = TubecamDevice.where(active: true).order(serialnumber: 'ASC')
  end

  # GET /sequences/1
  def show
    if @sequence.deleted
      redirect_to sequences_path, alert: t('flash.sequences.deactivated')
    end
    sequence = Sequence.find(params[:id])
    @media = sequence.media.order('frame ASC')
    @media = @media.paginate(per_page: 15, page: params[:page])
    @image_url = "https://#{ENV['S3_HOST_NAME']}/#{ENV['S3_BUCKET_NAME']}/"
    @thumbnail_url = "#{@image_url}thumbnails/"
    @tubecam_device = TubecamDevice.find(sequence.tubecam_device_id)
    @annotations = Annotation.where(sequence_id: sequence.id).order('verified_id ASC, created_at DESC')
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
  def create
    @sequence = Sequence.new(sequence_params)
    if @sequence.save
      redirect_to @sequence, notice: t('flash.sequences.create_success')
    else
      render :new
    end
  end

  # PATCH/PUT /sequences/1
  def update
    if @sequence.update(sequence_params)
      redirect_to @sequence, notice: t('flash.sequences.update_success')
    else
      render :edit
    end
  end

  # DELETE /sequences/1
  def destroy
    @sequence.destroy
    redirect_to sequences_url, notice: t('flash.sequences.destroy_success')
  end

  def deactivate
    @sequence = set_sequence
    tubecam_device_id = @sequence.tubecam_device_id
    if (current_user.admin_role? || current_user.trapper_role?) && @sequence.update(:deleted => true)
      redirect_to tubecam_device_url(tubecam_device_id), notice: t('flash.sequences.deactivate_success')
    else
      redirect_to tubecam_device_url(tubecam_device_id), alert: t('flash.sequences.deactivate_fail')
    end
  end

  # Set sequence active
  def activate
    @sequence = set_sequence
    tubecam_device_id = @sequence.tubecam_device_id
    if (current_user.admin_role? || current_user.trapper_role?) && @sequence.update(:deleted => false)
      redirect_to tubecam_device_url(tubecam_device_id), notice: t('flash.sequences.activate_success')
    else
      redirect_to tubecam_device_url(tubecam_device_id), alert: t('flash.sequences.activate_fail')
    end
  end

  def verify
    annotation = Annotation.find(params[:annotation_id])
    annotated = Annotation.where(sequence_id: annotation.sequence.id).where.not(verified_id: nil)
    if user_signed_in? && current_user.verified_spotter_role? && annotation.update(verified_id: current_user.id)
      redirect_to sequence_path(annotation.sequence.id), notice: t('flash.sequences.verify_success')
    else
      redirect_to sequence_path(annotation.sequence.id), alert: t('flash.sequences.verify_fail')
    end
  end

  def unverify
    annotation = Annotation.find(params[:annotation_id])
    if user_signed_in? && current_user.verified_spotter_role? && annotation.update(verified_id: nil)
      redirect_to sequence_path(annotation.sequence.id), notice: t('flash.sequences.verification_destroy_success')
    else
      redirect_to sequence_path(annotation.sequence.id), alert: t('flash.sequences.verification_destroy_fail')
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
      filter_date_start = Medium.select(:sequence_id).where(['datetime >=  ?', @filter_params[:date_start]]).distinct.pluck(:sequence_id)
      sequences = sequences.where(id: filter_date_start) if !filter_date_start.nil?
    end

    if !params[:date_end].nil? && !params[:date_end].empty?
      @filter_params[:date_end] = string_to_date(params[:date_end], '22:59:59')
      filter_date_end = Medium.select(:sequence_id).where(['datetime <=  ?', @filter_params[:date_end]]).distinct.pluck(:sequence_id)
      sequences = sequences.where(id: filter_date_end) if !filter_date_end.nil?
    end

    if !params[:lookup_table_id].nil? && !params[:lookup_table_id].empty?
      @filter_params[:lookup_table_id] = params[:lookup_table_id]
      lookup_table_id = params[:lookup_table_id]
      annotation_id = AnnotationsLookupTable.find(lookup_table_id).annotation_id
      first, second, third = annotation_id.to_s.split('')
      if /000/.match(annotation_id)
        # Matchs ids with empty picture annotation
        annotations = AnnotationsLookupTable.where(annotation_id: annotation_id).select(:id).pluck(:id)
        sequence_ids = Annotation.where(annotations_lookup_table_id: annotations).select(:sequence_id)
        sequences = sequences.where(id: sequence_ids) if !annotations.nil?
      elsif /[1-9]00/.match(annotation_id)
        # Matchs all ids of a family
        search = '' + first + '[0-9]' + '[0-9]'
        annotations = AnnotationsLookupTable.where("annotation_id ~* ?", search).select(:id).pluck(:id)
        sequence_ids = Annotation.where(annotations_lookup_table_id: annotations).select(:sequence_id)
        sequences = sequences.where(id: sequence_ids) if !annotations.nil?
      elsif /[1-9][1-9]0/.match(annotation_id)
        # Matchs all ids of a subclass
        search = '' + first + second + '[0-9]'
        annotations = AnnotationsLookupTable.where("annotation_id ~* ?", search).select(:id).pluck(:id)
        sequence_ids = Annotation.where(annotations_lookup_table_id: annotations).select(:sequence_id)
        sequences = sequences.where(id: sequence_ids) if !annotations.nil?
      else
        # Matchs one specific id
        annotations = AnnotationsLookupTable.where(annotation_id: annotation_id).select(:id).pluck(:id)
        sequence_ids = Annotation.where(annotations_lookup_table_id: annotations).select(:sequence_id)
        sequences = sequences.where(id: sequence_ids) if !annotations.nil?
      end

    end

    sequences
  end

  # scope :date_start, -> (date_start) { where("datetime > ?", date_start) } if !:date_start.empty?

  def string_to_date date_string, time
    if !date_string.empty?
      date_start_string = date_string.split(".")
      date_start_string = date_start_string[2] + ":" + date_start_string[1] + ":" + date_start_string[0] + " " + time
      date_start = Time.strptime(date_start_string, '%Y:%m:%d %H:%M:%S')
      date_string = date_start
    end
    date_string
  end


end
