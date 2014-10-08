module MailerHelper
  def display_name(user)
    return "Someone" unless user.present?
    user.full_name.presence || user.username
  end
end
