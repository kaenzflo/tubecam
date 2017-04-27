class TubecamDevice < ApplicationRecord
  belongs_to :user
  has_many :media, :dependent => :destroy
end
