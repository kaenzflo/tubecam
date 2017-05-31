##
# Handles users requests, provides CRUD functions. Provides possibility
# to activated or deactivated a user.
##
class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy activate deactivate]

  load_and_authorize_resource

  # Lists all useers
  def index
    @users = User.all.order(:id)
  end

  # Shows a specific user
  def show

  end

  # Edits user
  def edit
    if User.find(params[:id]).username == 'admin'
      redirect_to user_path(@user.id), alert: t('flash.users.user_not_editable')
    end
  end

  # Saves user to database
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to action: "index", notice: t('flash.users.create_success')
    else
      render :new
    end
  end

  # Updates user in database
  def update
    if @user.update(user_params)
      redirect_to action: "index", notice: t('flash.users.update_success')
    else
      render :edit
    end
  end

  # Destroys user
  def destroy
    @user.destroy
    redirect_to users_url, notice: t('flash.users.destroy_success')
  end

  # Sets user inactive
  def deactivate
    if current_user.admin_role? && @user.update(active: false)
      redirect_to users_path, notice: t('flash.users.deactivate_success')
    else
      redirect_to users_path, alert: t('flash.users.deactivate_fail')
    end
  end

  # Sets user active
  def activate
    if current_user.admin_role? && @user.update(active: true)
      redirect_to users_path, notice: t('flash.users.activate_success')
    else
      redirect_to users_path, alert: t('flash.users.activate_fail')
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :username, :firstname, :lastname, :spotter_role, :verified_spotter_role, :trapper_role, :admin_role, :active, :trapper_role, :admin_role)
  end
end
