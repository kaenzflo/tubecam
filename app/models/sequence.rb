class Sequence < ApplicationRecord
  belongs_to :tubecam_device
  has_many :media, :dependent => :destroy
  has_many :annotation, :dependent => :destroy

  # Use scoping for filteroptions in media gallery
  include Filterable
  scope :tubecam_device_id, -> (tubecam_device_id) { where tubecam_device_id: tubecam_device_id } if !:tubecam_device_id.empty?
  scope :sequence, -> (sequence) { where sequence: sequence } if !:sequence.empty?

  # Pagination: Amount of items per page
  self.per_page = 10

  validates :tubecam_device_id, uniqueness: { scope: :sequence_no }
end
