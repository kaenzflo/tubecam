class Medium < ApplicationRecord
  belongs_to :tubecam_device

  include Filterable

  scope :tubecam_device_id, -> (tubecam_device_id) { where tubecam_device_id: tubecam_device_id }
  scope :sequence, -> (sequence) { where sequence: sequence }
  scope :date_start, -> (date_start) { where("datetime > ?", date_start) } if !:date_start.empty?
  scope :date_end, -> (date_end) { where("datetime < ?", date_end) } if !:date_end.empty?
end
