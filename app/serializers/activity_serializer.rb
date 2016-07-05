class ActivitySerializer < ActiveModel::Serializer
  has_one :user, include: false, embed: :id

  attributes :message,
             :user_full_name,
             :user_avatar_url,
             :created_at,

  def user_full_name
    user.full_name
  end

  def user_avatar_url
    if user
      user.avatar_url
    else
      AvatarUploader::DEFAULT_URL
    end
  end
end
