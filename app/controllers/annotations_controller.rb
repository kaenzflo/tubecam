# Annotate sequences
class AnnotationsController < ApplicationController

  # List all annotations
  def index
    if current_user.admin_role
      @annotations = Annotation.all
    else
      @annotations = Annotation.where(user_id: current_user.id).order('created_at DESC')
    end
    @annotations = @annotations.order('id DESC')
                               .paginate(per_page: 15, page: params[:page])
    @annotations_lookup_table = AnnotationsLookupTable.all.order('id ASC')
    @users = User.all
    @image_url = 'https://' +
                 ENV['S3_HOST_NAME'] + '/' +
                 ENV['S3_BUCKET_NAME'] + '/'
    @thumbnail_url = @image_url + 'thumbnails/'
  end

  # Create new annotation
  def new
    @user = current_user
    available_sequences = Sequence.where(deleted: false)
    sequences = available_sequences.where.not(id: Annotation.where(user_id: @user.id)
                                                            .select('sequence_id'))
    if sequences.empty?
      redirect_to '/annotations/done'
    else
      sequence = sequences[rand(0...sequences.size)]
      sequence_media = Medium.where(sequence_id: sequence.id, deleted: false)
                             .order('frame ASC')
      @medium = sequence_media.first
      instantiate_vars(sequence_media)
    end
  end

  # Annotate a specific sequence
  def specific
    @user = current_user
    medium = Medium.find(specific_params[:id])
    if !Annotation.where(sequence_id: medium.sequence_id, user_id: @user.id).empty?
      redirect_to new_annotation_path, alert: t('flash.annotations.media_already_annotated')
    else
      @medium = medium
      sequence_media = Medium.where(deleted: false, sequence_id: medium.sequence_id).order('frame ASC')
      instantiate_vars(sequence_media)
    end
  end

  # Create annotation
  def create
    @annotation = Annotation.new(annotations_params)
    if current_user.verified_spotter_role?
      set_verified_id
    end
    if @annotation.annotations_lookup_table_id != '' &&
       @annotation.user_id == current_user.id &&
       @annotation.save
      redirect_to new_annotation_path, notice: t('flash.annotations.create_success')
    else
      redirect_to new_annotation_path, alert: t('flash.annotations.create_fail')
    end
  end

  # Delete annotation
  def destroy
    @annotation = Annotation.find(destroy_params[:id])
    @annotation.destroy
    redirect_to sequence_path(destroy_params[:sequence_id]), notice: t('flash.annotations.destroy_success')
  end

  private

  # Instantiate variables for specific and new method
  def instantiate_vars(sequence_media)
    @thumbnails = sequence_media.where(frame: (@medium.frame - 2)..(@medium.frame + 5))
                                .order('frame ASC')
    @image_url = 'https://' +
                 ENV['S3_HOST_NAME'] + '/' +
                 ENV['S3_BUCKET_NAME'] + '/'
    @thumbnail_url = @image_url + 'thumbnails/'
    @annotations_lookup_table = AnnotationsLookupTable.all.order('annotation_id')
    @annotation = Annotation.new

    @media_amount = @medium.sequence.media.count
  end

  # Set verified field if spotter is verified
  def set_verified_id
    annotations = Annotation.where(sequence_id: annotations_params[:sequence_id])
                            .where.not(verified_id: nil)
    annotations.each do |annotation|
      annotation.verified_id = nil
      annotation.save
    end
    @annotation.verified_id = current_user.id
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def annotations_params
    params.require(:annotation).permit(:user_id, :sequence_id,
                                       :annotations_lookup_table_id)
  end

  def specific_params
    params.permit(:id)
  end

  def destroy_params
    params.permit(:sequence_id, :id)
  end

end