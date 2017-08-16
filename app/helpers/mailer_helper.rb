module MailerHelper
  def app_name
    TahiEnv.app_name
  end

  def prefixed(subject)
    prefix = default_url_options[:host]
    "[#{prefix}] #{subject}"
  end

  def display_name(user)
    return "Someone" unless user.present?
    user.full_name.presence || user.username
  end

  def prevent_delivery_to_invalid_recipient
    mail.perform_deliveries = false if mail.to.empty?
  end
end
