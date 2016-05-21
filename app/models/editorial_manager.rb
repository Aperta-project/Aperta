# Retrieve GUIDs from EM database for Authors in Aperta
# https://schneide.wordpress.com/2014/03/10/using-rails-with-a-legacy-database-schema/

class EditorialManager < ActiveRecord::Base
  establish_connection ENV['EM_DATABASE_URL'].present? ? ENV['EM_DATABASE_URL'] : "editorial_manager_#{Rails.env}".to_sym
end

class EmPeople < EditorialManager
  has_many :addresses, class_name: 'EmAddress', foreign_key: 'peopleid'

  self.table_name = 'people'
  self.primary_key = 'peopleid'

  def self.find_or_create_guid_by_email(email:)
    user = User.find_by(email: email)
    return user.em_guid if user.present? && user.em_guid.present?
    return unless email
    email.strip!

    person = EmPeople.joins(:addresses).where('address.email LIKE ?', email).first
    if person.present?
      guid = person.GUID
      if user.present?
        user.update_attribute(:em_guid, guid)
        guid
      else
        guid
      end
    end
  end
end

class EmAddress < EditorialManager
  belongs_to :people, class_name: 'EmPeople', foreign_key: 'peopleid'
  self.table_name = 'address'
  self.primary_key = 'addressid'
end
