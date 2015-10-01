#
# This class is to establish a connection to EM
# and retrieve GUIDs for Authors in Aperta
#
class PlosEditorialManager < ActiveRecord::Base
  establish_connection :plos_editorial_manager

  def self.find_person_by_email(email:)
    email = email.strip
    sql = "SELECT TOP (1) * FROM PEOPLE JOIN ADDRESS ON (PEOPLE.PEOPLEID = ADDRESS.PEOPLEID) WHERE ADDRESS.EMAIL LIKE '%#{email}%'"
    query(sql)
  end

  def self.query(sql)
    connection.exec_query(sql).to_hash
  end
end
