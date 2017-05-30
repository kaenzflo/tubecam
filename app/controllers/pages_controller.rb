require 'csv'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:project, :contact]

  def project
    render template: "pages/project"
  end

  def contact
    render template: "pages/contact"
  end

  def dashboard
    render template: "pages/dashboard"
  end
end
