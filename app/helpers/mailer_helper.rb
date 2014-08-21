module MailerHelper
  def display_name(user)
    user.full_name.present? ? user.full_name : user.username
  end
end
