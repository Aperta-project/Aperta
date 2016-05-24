# Retrieve GUIDs from EM database for Authors in Aperta
# https://schneide.wordpress.com/2014/03/10/using-rails-with-a-legacy-database-schema/

module EditorialManager
  def self.find_or_create_guid_by_email(email:)
    user = User.find_by(email: email)
    return unless user
    return user.em_guid if user.em_guid

    if ENV['EM_DATABASE_URL'].present?
      EmPeople.create_guid_by_email(email: email).tap do |guid|
        user.update_attribute(:em_guid, guid) if guid
      end
    else
      Rails.logger.info <<-MESSAGE.strip_heredoc
        EDITORIAL MANAGER CONNECTION NOT ESTABLISHED. We attempted to connect
        to EditorialManager, but its connection was not established. This may
        be correct for this environment, but if it isn't make sure that the
        EM_DATABASE_URL environment variable is set.

        Called from:
          #{caller[0..5].join("\n  ")}
      MESSAGE
    end
  end

  class Base < ActiveRecord::Base
    if ENV['EM_DATABASE_URL'].present?
      establish_connection ENV['EM_DATABASE_URL']
    else
      Rails.logger.info <<-MESSAGE.strip_heredoc
        EM_DATABASE_URL environment variable not set. Skipping establishing a
        connection to Editorial Manager.
      MESSAGE
    end
  end

  # This classes is only a helper class for Editorial Manager and is not meant to be
  # publically consumed
  class EmPeople < Base
    has_many :addresses, class_name: 'EmAddress', foreign_key: 'peopleid'

    self.table_name = 'people'
    self.primary_key = 'peopleid'

    def self.create_guid_by_email(email:)
      email.strip!

      person = EmPeople.joins(:addresses).where('address.email LIKE ?', email).first
      guid = person.GUID if person.present?
    end
  end

  # This classes is only a helper class for Editorial Manager and is not meant to be
  # publically consumed
  class EmAddress < Base
    belongs_to :people, class_name: 'EmPeople', foreign_key: 'peopleid'
    self.table_name = 'address'
    self.primary_key = 'addressid'
  end
end
