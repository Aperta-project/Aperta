class Journal < ActiveRecord::Base
  has_many :papers

  mount_uploader :logo, LogoUploader
end
