class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!


  def welcome

  end

  def after_sign_in_path_for(resource)
    new_annotation_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_url, :alert => exception.message
  end

  def page_not_found
    respond_to do |format|
      format.html { render template: 'errors/not_found_error', layout: 'layouts/application', status: 404 }
      format.all  { render nothing: true, status: 404 }
    end
  end

end
