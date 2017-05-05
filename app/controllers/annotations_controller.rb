class AnnotationsController < ApplicationController

  def new
    @user = current_user
    media = Medium.where.not(id: MediumAnnotation.where(user_id: @user.id).select('medium_id'))
    random = rand(0...media.size)
    @medium = media[random]
    @cloud_resource_image_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/'
    @annotations_lookup_table = AnnotationsLookupTable.all
    @medium_annotation = MediumAnnotation.new
  end

  def create
    @medium_annotation = MediumAnnotation.new(annotations_params)
    respond_to do |format|
      if @medium_annotation.annotations_lookup_table_id != '' &&
          @medium_annotation.user_id == current_user.id &&
          @medium_annotation.save
        format.html { redirect_to '/annotations/new', notice: 'Medium was successfully annotated' }
        format.json { render :'annotations/new', status: :created, location: @medium_annotation }
      else
        format.html { redirect_to '/annotations/new', notice: 'Annotation failed :(' }
        format.json { render json: @medium_annotation.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def annotations_params
    params.require(:medium_annotation).permit(:user_id, :medium_id, :annotations_lookup_table_id)
  end


end


