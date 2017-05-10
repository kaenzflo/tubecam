class AnnotationsController < ApplicationController

  def new
    @user = current_user
    available_sequences = Sequence.where(deleted: false)
    sequences = available_sequences.where.not(id: Annotation.where(user_id: @user.id).select('sequence_id'))
    sequence = sequences[rand(0...sequences.size)]
    media = Medium.where(sequence_id: sequence.id, deleted: false)
    @medium = media.first
    instantiate_vars(media)
  end

  def create
    @medium_annotation = Annotation.new(annotations_params)
    respond_to do |format|
      if @medium_annotation.annotations_lookup_table_id != '' &&
          @medium_annotation.user_id == current_user.id &&
          @medium_annotation.save
        format.html { redirect_to '/annotations/new', notice: 'Medium erfolgreich annotiert' }
        format.json { render :'annotations/new', status: :created, location: @medium_annotation }
      else
        format.html { redirect_to '/annotations/new', alert: 'Annotation fehlgeschlagen' }
        format.json { render json: @medium_annotation.errors, status: :unprocessable_entity }
      end
    end
  end

  def specific
    @user = current_user
    media = Medium.all
    available_media = media.where(deleted: false)
    own_annotations = Annotation.where(user_id: @user.id)
    medium = available_media.find(specific_param[:id])
    p '##############'
    p medium.sequence_id.inspect
    if own_annotations.where(sequence_id: medium.sequence_id)
      redirect_to '/annotations/new', alert: 'Medium bereits annotiert'
    else
      @medium = available_media.find(specific_param[:id])
      instantiate_vars(available_media)
    end
  end

  def index

  end

  private

  def instantiate_vars(media)
    @thumbnails = media.where(frame: @medium.frame..(@medium.frame + 3))
    @cloud_resource_image_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/'
    @cloud_resource_thumbnail_url = @cloud_resource_image_url + 'thumbnails/'
    @annotations_lookup_table = AnnotationsLookupTable.all.order('annotation_id')
    @annotation = Annotation.new
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def annotations_params
    params.require(:medium_annotation).permit(:user_id, :medium_id, :annotations_lookup_table_id)
  end

  def specific_param
    params.permit(:id)
  end


end

