require 'csv'
##
# Handles data export requests
##
class ExportsController < ApplicationController

  # Sends data as comma separated values (CSV) to requester
  def index
    @annotations_lookup_table = AnnotationsLookupTable.all.order('id ASC')
    @users = User.all
    @media = Medium.all
    @annotations = Annotation.all
    @sequences = Sequence.all
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename='tubecam_data.csv'"
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

end