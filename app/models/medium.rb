class Medium < ApplicationRecord
  belongs_to :sequence

  # Use scoping for filteroptions in media gallery
  include Filterable
  scope :sequence, -> (sequence) { where sequence: sequence } if !:sequence.empty?
  scope :date_start, -> (date_start) { where("datetime > ?", date_start) } if !:date_start.empty?
  scope :date_end, -> (date_end) { where("datetime < ?", date_end) } if !:date_end.empty?

  # Pagination: Amount of items per page
  self.per_page = 16
end
