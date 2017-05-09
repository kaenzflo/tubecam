class Sequence < ApplicationRecord
  belongs_to :tubecam_device
  has_many :media, :dependent => :destroy
end
