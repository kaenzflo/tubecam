class TubecamDevice < ApplicationRecord
  belongs_to :user
  has_many :media, :dependent => :destroy

  # Pagination: Amount of items per page
  self.per_page = 15
end
