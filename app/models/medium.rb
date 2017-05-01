class Medium < ApplicationRecord
  belongs_to :tubecam_device

  include Filterable

  scope :tubecam_device_id, -> (tubecam_device_id) { where tubecam_device_id: tubecam_device_id }
  scope :sequence, -> (sequence) { where sequence: sequence }
end
