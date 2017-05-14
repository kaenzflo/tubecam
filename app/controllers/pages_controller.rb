require 'csv'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:project, :contact]

  def project
    render template: "pages/project"
  end

  def dataexport
    @annotations = Annotation.all
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename='tubecam_project.csv'"
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def contact
    render template: "pages/contact"
  end

  def dashboard
    render template: "pages/dashboard"
  end
end
