class AnnotationsController < ApplicationController

  def new
    @user = current_user
    available_sequences = Sequence.where(deleted: false)
    sequences = available_sequences.where.not(id: Annotation.where(user_id: @user.id).select('sequence_id'))
    if sequences.empty?
      redirect_to '/annotations/done'
    else
      sequence = sequences[rand(0...sequences.size)]
      sequence_media = Medium.where(sequence_id: sequence.id, deleted: false).order('frame ASC')
      @medium = sequence_media.first
      instantiate_vars(sequence_media)
    end
  end

  def specific
    @user = current_user
    medium = Medium.find(specific_param[:id])
    if !Annotation.where(sequence_id: medium.sequence_id, user_id: @user.id).empty?
      redirect_to '/annotations/new', alert: 'Medium bereits annotiert: Anderes Medium wird angezeigt'
    else
      @medium = medium
      sequence_media = Medium.where(deleted: false, sequence_id: medium.sequence_id).order('frame ASC')
      instantiate_vars(sequence_media)
    end
  end

  def create
    @annotation = Annotation.new(annotations_params)
    respond_to do |format|
      if @annotation.annotations_lookup_table_id != '' &&
          @annotation.user_id == current_user.id &&
          @annotation.save
        format.html { redirect_to '/annotations/new', notice: 'Medium erfolgreich annotiert' }
        format.json { render :'annotations/new', status: :created, location: @annotation }
      else
        format.html { redirect_to '/annotations/new', alert: 'Annotation fehlgeschlagen' }
        format.json { render json: @annotation.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    @annotations = Annotation.all
    @annotations_lookup_table = AnnotationsLookupTable.all.order('id ASC')
    @users = User.all
    @user = current_user
  end

  def destroy
    @annotation = Annotation.find(destroy_param[:id])
    @annotation.destroy
    respond_to do |format|
      format.html { redirect_to annotations_path, notice: 'Annotation gelöscht' }
      format.json { head :no_content }
    end
  end

  private

  def instantiate_vars(sequence_media)
    @thumbnails = sequence_media.where(frame: (@medium.frame - 1)..(@medium.frame + 4)).order('frame ASC')
    @cloud_resource_image_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/'
    @cloud_resource_thumbnail_url = @cloud_resource_image_url + 'thumbnails/'
    @annotations_lookup_table = AnnotationsLookupTable.all.order('annotation_id')
    @annotation = Annotation.new
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def annotations_params
    params.require(:annotation).permit(:user_id, :sequence_id, :annotations_lookup_table_id)
  end

  def specific_param
    params.permit(:id)
  end

  def destroy_param
    params.permit(:id)
  end

end