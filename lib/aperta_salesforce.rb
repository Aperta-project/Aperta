class ApertaSalesforce

  attr_accessor :client

  def initialize
    client = Databasedotcom::Client.new host: Rails.configuration.salesforce_host
    client.authenticate :username => Rails.configuration.salesforce_username,
                        :password => Rails.configuration.salesforce_password

    client
  end
end
