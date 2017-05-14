require 'csv'

class ExportsController < ApplicationController

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