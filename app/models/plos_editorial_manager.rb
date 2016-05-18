# Retrieve GUIDs from EM database for Authors in Aperta
#

class PlosEditorialManager < ActiveRecord::Base
  def self.find_or_create_guid_by_email(email:)
    user = User.find_by(email: email)
    return user.em_guid if user.present? && user.em_guid.present?

    @connection ||= establish_connection(ENV['EM_DATABASE_URL'])
    email = email.strip
    sql = "SELECT TOP (1) * FROM PEOPLE JOIN ADDRESS ON (PEOPLE.PEOPLEID = ADDRESS.PEOPLEID) WHERE ADDRESS.EMAIL LIKE '%#{email}%'"
    results = query(sql)
    if results.one?
      guid = results.first['GUID']
      if user.present?
        user.update_attribute(:em_guid, guid)
        guid
      else
        guid
      end
    end
  end

  def self.query(sql)
    connection.exec_query(sql).to_hash
  end
end
