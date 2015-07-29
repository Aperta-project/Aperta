module MailerHelper

  def app_name
    ENV["APP_NAME"] || 'Aperta'
  end

  def display_name(user)
    return "Someone" unless user.present?
    user.full_name.presence || user.username
  end

  def prevent_delivery_to_invalid_recipient
    if mail.to.empty?
      mail.perform_deliveries = false
    end
  end
end
