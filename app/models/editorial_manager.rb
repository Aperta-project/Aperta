# Retrieve GUIDs from EM database for Authors in Aperta
# https://schneide.wordpress.com/2014/03/10/using-rails-with-a-legacy-database-schema/

class EditorialManager < ActiveRecord::Base
  if ENV['EM_DATABASE_URL'].present?
    establish_connection ENV['EM_DATABASE_URL']
  end

  def self.find_or_create_guid_by_email(email:)
    user = User.find_by(email: email)
    return unless user
    if user.em_guid
      user.em_guid
    elsif connected?
      EmPeople.create_guid_by_email(email: email).tap do |guid|
        user.update_attribute(:em_guid, guid) if guid
      end
    end
  end
end

class EmPeople < EditorialManager
  has_many :addresses, class_name: 'EmAddress', foreign_key: 'peopleid'

  self.table_name = 'people'
  self.primary_key = 'peopleid'

  def self.create_guid_by_email(email:)
    email.strip!

    person = EmPeople.joins(:addresses).where('address.email LIKE ?', email).first
    guid = person.GUID if person.present?
  end
end

class EmAddress < EditorialManager
  belongs_to :people, class_name: 'EmPeople', foreign_key: 'peopleid'
  self.table_name = 'address'
  self.primary_key = 'addressid'
end
