class AnnotationsController < ApplicationController

  def new
    @user = current_user
    available_media = Medium.where(deleted: false)
    media = available_media.where.not(id: MediumAnnotation.where(user_id: @user.id).select('medium_id'))
    random = rand(0...media.size)
    @medium = media[random]
    instantiate_annotation_variables(media)
  end

  def create
    @medium_annotation = MediumAnnotation.new(annotations_params)
    respond_to do |format|
      if @medium_annotation.annotations_lookup_table_id != '' &&
          @medium_annotation.user_id == current_user.id &&
          @medium_annotation.save
        format.html { redirect_to '/annotations/new', notice: 'Medium erfolgreich annotiert' }
        format.json { render :'annotations/new', status: :created, location: @medium_annotation }
      else
        format.html { redirect_to '/annotations/new', warn: 'Annotation fehlgeschlagen' }
        format.json { render json: @medium_annotation.errors, status: :unprocessable_entity }
      end
    end
  end

  def specific
    @user = current_user
    available_media = Medium.where(deleted: false)
    @medium = available_media.find(specific_param[:id])
    media = Medium.all
    instantiate_annotation_variables(media)
  end

  def index

  end

  private

  def instantiate_annotation_variables(media)
    @thumbnails = media.where(sequence: @medium.sequence, frame: @medium.frame..(@medium.frame + 3))
    @cloud_resource_image_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/'
    @cloud_resource_thumbnail_url = @cloud_resource_image_url + 'thumbnails/'
    @annotations_lookup_table = AnnotationsLookupTable.all.order('annotation_id')
    @medium_annotation = MediumAnnotation.new
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def annotations_params
    params.require(:medium_annotation).permit(:user_id, :medium_id, :annotations_lookup_table_id)
  end

  def specific_param
    params.permit(:id)
  end


end

