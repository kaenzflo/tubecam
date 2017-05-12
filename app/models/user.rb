class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :confirmable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable
  has_many :tubecam_devices, :dependent => :destroy
end
