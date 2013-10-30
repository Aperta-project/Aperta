class User < ActiveRecord::Base
  has_many :papers

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
