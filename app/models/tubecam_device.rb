class TubecamDevice < ApplicationRecord
  belongs_to :user
  has_many :sequences, :dependent => :destroy

  # Pagination: Amount of items per page
  self.per_page = 15
end
