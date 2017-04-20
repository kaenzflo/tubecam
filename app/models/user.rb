class User < ApplicationRecord
  has_many :tubecamstations, :dependent => :destroy
end
