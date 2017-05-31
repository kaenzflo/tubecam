##
# Handles sequence requests, provides CRUD functions, possibility to
# verify an annotation as verified spotter and applies a filter to
# the sequence gallery
##
class SequencesController < ApplicationController
  before_action :set_sequence, only: %i[show edit update destroy]

  load_and_authorize_resource
  skip_before_filter :authenticate_user!
  skip_authorize_resource only: %i[index show verify unverify]

  # Lists all sequences
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
    @tubecam_devices = TubecamDevice.where(active: true)
                                    .order(serialnumber: :asc)
  end

  # Shows a specific sequence
  def show
    if @sequence.deleted
      redirect_to sequences_path, alert: t('flash.sequences.deactivated')
    end
    sequence = Sequence.find(params[:id])
    @media = sequence.media.order(frame: :asc)
    @media = @media.paginate(per_page: 15, page: params[:page])
    @image_url = "https://#{ENV['S3_HOST_NAME']}/#{ENV['S3_BUCKET_NAME']}/"
    @thumbnail_url = "#{@image_url}thumbnails/"
    @tubecam_device = TubecamDevice.find(sequence.tubecam_device_id)
    @annotations = Annotation.where(sequence_id: sequence.id)
                             .order('verified_id ASC, created_at DESC')
    @annotations_lookup_table = AnnotationsLookupTable.all
  end

  # New sequence
  def new
    @sequence = Sequence.new
  end

  # Creates a new sequence
  def create
    @sequence = Sequence.new(sequence_params)
    if @sequence.save
      redirect_to @sequence, notice: t('flash.sequences.create_success')
    else
      render :new
    end
  end

  # Updates a sequence
  def update
    if @sequence.update(sequence_params)
      redirect_to @sequence, notice: t('flash.sequences.update_success')
    else
      render :edit
    end
  end

  # Destroys a sequence
  def destroy
    @sequence.destroy
    redirect_to sequences_url, notice: t('flash.sequences.destroy_success')
  end

  # Deactivates a sequence
  def deactivate
    @sequence = set_sequence
    tubecam_device_id = @sequence.tubecam_device_id
    if (current_user.admin_role? || current_user.trapper_role?) && @sequence.update(deleted: true)
      redirect_to tubecam_device_url(tubecam_device_id), notice: t('flash.sequences.deactivate_success')
    else
      redirect_to tubecam_device_url(tubecam_device_id), alert: t('flash.sequences.deactivate_fail')
    end
  end

  # Activates a sequence
  def activate
    @sequence = set_sequence
    tubecam_device_id = @sequence.tubecam_device_id
    if (current_user.admin_role? || current_user.trapper_role?) && @sequence.update(deleted: false)
      redirect_to tubecam_device_url(tubecam_device_id), notice: t('flash.sequences.activate_success')
    else
      redirect_to tubecam_device_url(tubecam_device_id), alert: t('flash.sequences.activate_fail')
    end
  end

  # Verifies an annotation (possible only for verified spotters)
  def verify
    annotation = Annotation.find(params[:annotation_id])
    if user_signed_in? &&
       current_user.verified_spotter_role? &&
       annotation.update(verified_id: current_user.id)
      redirect_to sequence_path(annotation.sequence.id), notice: t('flash.sequences.verify_success')
    else
      redirect_to sequence_path(annotation.sequence.id), alert: t('flash.sequences.verify_fail')
    end
  end

  # Deletes an annotation's verification (possible only for verified spotters)
  def unverify
    annotation = Annotation.find(params[:annotation_id])
    if user_signed_in? &&
       current_user.verified_spotter_role? &&
       annotation.update(verified_id: nil)
      redirect_to sequence_path(annotation.sequence.id), notice: t('flash.sequences.verification_destroy_success')
    else
      redirect_to sequence_path(annotation.sequence.id), alert: t('flash.sequences.verification_destroy_fail')
    end
  end

  private

  # Common setup or constraints between actions.
  def set_sequence
    @sequence = Sequence.find(params[:id])
  end

  # White listing parameters for 'create' and 'update'
  def sequence_params
    params.require(:sequence).permit(:path, :filename, :sequencestype, :datetime,
                                     :longitude, :latitude, :sequence, :frame,
                                     :tubecam_device_id, :exifdata, :deleted)
    # Additional for filtering gallery
    params.require(:sequence).permit(:date_start, :date_end, :lookup_table_id)
  end

  # White listing parameters for 'index'
  def scope_params
    scope_params = params.slice(:tubecam_device_id, :sequence)
  end

  # Applies a filter by time period and by 'lookup_table_id' (annotation)
  # to the sequences list
  def filter_sequences(sequences)
    sequences = filter_by_start_date(sequences)
    sequences = filter_by_end_date(sequences)
    sequences = filter_by_lookup_table_id(sequences)
    sequences
  end

  # Filters sequences by start date
  def filter_by_start_date(sequences)
    if !params[:date_start].nil? && !params[:date_start].empty?
      @filter_params[:date_start] = string_to_date(params[:date_start],
                                                   '00:00:00')
      filter_date_start = Medium.select(:sequence_id)
                                .where(['datetime >=  ?', @filter_params[:date_start]])
                                .distinct.pluck(:sequence_id)
      !filter_date_start.nil? ? sequences = sequences.where(id: filter_date_start) : nil
    end
    sequences
  end

  # Filters sequences by end date
  def filter_by_end_date(sequences)
    if !params[:date_end].nil? && !params[:date_end].empty?
      @filter_params[:date_end] = string_to_date(params[:date_end], '22:59:59')
      filter_date_end = Medium.select(:sequence_id)
                              .where(['datetime <=  ?', @filter_params[:date_end]])
                              .distinct.pluck(:sequence_id)
      !filter_date_end.nil? ? sequences = sequences.where(id: filter_date_end) : nil
    end
    sequences
  end

  # Filter sequences by lookup_table_id
  def filter_by_lookup_table_id(sequences)
    if !params[:lookup_table_id].nil? && !params[:lookup_table_id].empty?
      @filter_params[:lookup_table_id] = params[:lookup_table_id]
      annotations = filter_by_hierarchy
      sequence_ids = Annotation.where(annotations_lookup_table_id: annotations).select(:sequence_id)
      !annotations.nil? ? sequences = sequences.where(id: sequence_ids) : nil
    end
    sequences
  end

  # Filter sequences by taxonomical hierarchical level (family, genus, species)
  def filter_by_hierarchy
    lookup_table_id = params[:lookup_table_id]
    annotation_id = AnnotationsLookupTable.find(lookup_table_id).annotation_id
    first_digit, second_digit = annotation_id.to_s.split('')
    family_level = /[1-9]00/
    genus_level = /[1-9][1-9]0/
    if family_level.match(annotation_id)
      search = "#{first_digit}[0-9][0-9]"
      annotations = AnnotationsLookupTable.where('annotation_id ~* ?', search)
                                          .select(:id).pluck(:id)
    elsif genus_level.match(annotation_id)
      search = "#{first_digit}#{second_digit}[0-9]"
      annotations = AnnotationsLookupTable.where('annotation_id ~* ?', search)
                                          .select(:id).pluck(:id)
    else
      annotations = AnnotationsLookupTable.where(annotation_id: annotation_id)
                                          .select(:id).pluck(:id)
    end
    annotations
  end

  # Reformats date string
  def string_to_date(date_string, time)
    unless date_string.empty?
      date_start_string = date_string.split('.')
      date_start_string = "#{date_start_string[2]}:#{date_start_string[1]}:#{date_start_string[0]} #{time}"
      date_start = Time.strptime(date_start_string, '%Y:%m:%d %H:%M:%S')
      date_string = date_start
    end
    date_string
  end

end
