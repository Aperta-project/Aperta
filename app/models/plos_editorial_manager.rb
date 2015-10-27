# Retrieve GUIDs from EM database for Authors in Aperta
#
# You MUST establish a connection manually to an EM database before
# using this. e.g.
# =PlosEditorialManager.establish_connection("plos_editorial_manager_#{Rails.env}".to_sym)=

class PlosEditorialManager < ActiveRecord::Base

  def self.find_person_by_email(email:)
    email = email.strip
    sql = "SELECT TOP (1) * FROM PEOPLE JOIN ADDRESS ON (PEOPLE.PEOPLEID = ADDRESS.PEOPLEID) WHERE ADDRESS.EMAIL LIKE '%#{email}%'"
    query(sql)
  end

  def self.query(sql)
    connection.exec_query(sql).to_hash
  end
end
