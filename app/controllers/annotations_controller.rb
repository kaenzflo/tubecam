class AnnotationsController < ApplicationController

  def index
    if current_user.admin_role
      @annotations = Annotation.all
    else
      @annotations = Annotation.where(user_id: current_user.id).order('created_at DESC')
    end
    @annotations = @annotations.order('id DESC').paginate( per_page: 15, page: params[:page])
    @annotations_lookup_table = AnnotationsLookupTable.all.order('id ASC')
    @users = User.all
    @cloud_resource_image_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/'
    @cloud_resource_thumbnail_url = @cloud_resource_image_url + 'thumbnails/'
  end

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
      redirect_to '/annotations/new', alert: t('flash.annotations.media_already_annotated')
    else
      @medium = medium
      sequence_media = Medium.where(deleted: false, sequence_id: medium.sequence_id).order('frame ASC')
      instantiate_vars(sequence_media)
    end
  end

  def create
    @annotation = Annotation.new(annotations_params)
    if current_user.verified_spotter_role?
      set_verified_id
    end
    respond_to do |format|
      if @annotation.annotations_lookup_table_id != '' &&
          @annotation.user_id == current_user.id &&
          @annotation.save
        format.html { redirect_to '/annotations/new', notice: t('flash.annotations.create_success') }
        format.json { render :'annotations/new', status: :created, location: @annotation }
      else
        format.html { redirect_to '/annotations/new', alert: t('flash.annotations.create_fail') }
        format.json { render json: @annotation.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @annotation = Annotation.find(destroy_param[:id])
    @annotation.destroy
    respond_to do |format|
      format.html { redirect_to sequence_path(destroy_param[:sequence_id]), notice: t('flash.annotations.destroy_success') }
      format.json { head :no_content }
    end
  end

  private

  def instantiate_vars(sequence_media)
    @thumbnails = sequence_media.where(frame: (@medium.frame - 2)..(@medium.frame + 5)).order('frame ASC')
    @cloud_resource_image_url = 'https://' +
        ENV['S3_HOST_NAME'] + '/' +
        ENV['S3_BUCKET_NAME'] + '/'
    @cloud_resource_thumbnail_url = @cloud_resource_image_url + 'thumbnails/'
    @annotations_lookup_table = AnnotationsLookupTable.all.order('annotation_id')
    @annotation = Annotation.new

    @media_amount = @medium.sequence.media.count
  end

  def set_verified_id
    annotations = Annotation.where(sequence_id: annotations_params[:sequence_id]).where.not(verified_id: nil)
    annotations.each do |annotation|
      annotation.verified_id = nil
      annotation.save
    end
    @annotation.verified_id = current_user.id
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def annotations_params
    params.require(:annotation).permit(:user_id, :sequence_id, :annotations_lookup_table_id)
  end

  def specific_param
    params.permit( :id)
  end

  def destroy_param
    params.permit(:sequence_id, :id)
  end

end