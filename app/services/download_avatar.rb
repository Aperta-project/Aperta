class DownloadAvatar
  def self.call user, url
    user.avatar.download! url
    user.save
  end
end
