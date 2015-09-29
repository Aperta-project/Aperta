#
# This class is to establish a connection to EM
# and retrieve GUIDs for Authors in Aperta
#
class PlosEditorialManager < ActiveRecord::Base
  establish_connection "plos_editorial_manager_#{Rails.env}".to_sym

  class  << self
    def query(email)
      email = email.strip
      query = "SELECT TOP (1) * FROM PEOPLE JOIN ADDRESS ON (PEOPLE.PEOPLEID = ADDRESS.PEOPLEID) WHERE ADDRESS.EMAIL = '#{email}';"
      connection.exec_query(query).to_hash
    end

    def tables
      connection.tables
    end
  end
end
