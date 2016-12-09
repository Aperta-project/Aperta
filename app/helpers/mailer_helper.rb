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
    if mail.to.empty?
      mail.perform_deliveries = false
    end
  end

  def author_address(author)
    current_address_street = author.current_address_street
    current_address_city  = author.current_address_city
    current_address_state = author.current_address_state
    current_address_country = author.current_address_country
    current_address_postal = author.current_address_postal
    address = ""
    if current_address_street && current_address_city && current_address_country
      address << current_address_state << " " << current_address_city << " " <<
          current_address_state ? current_address_state + ", " : "" << current_address_country <<
          current_address_postal ? " "  + current_address_postal : ""
    end
    return address
  end
end
