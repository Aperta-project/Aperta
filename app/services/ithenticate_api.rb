require 'uri'
require 'xmlrpc/client'

# Class used for interacting with the Ithenticate API
class IthenticateApi
  def self.new_from_tahi_env
    uri = URI(TahiEnv.ITHENTICATE_URL)
    new(
      username: TahiEnv.ITHENTICATE_EMAIL,
      password: TahiEnv.ITHENTICATE_PASSWORD,
      host: uri.host,
      path: uri.path,
      use_ssl: uri.scheme == "https"
    )
  end

  def initialize(username:, password:, **opts)
    @username = username
    @password = password
    @server = XMLRPC::Client.new_from_hash(**opts)
  end

  def call(method:, **args)
    authenticated_args = args.dup
    authenticated_args[:sid] = sid
    unauthenticated_call(method, **authenticated_args)
  end

  def login
    response = unauthenticated_call(
      "login",
      username: @username,
      password: @password
    )
    sid = response["sid"]
    raise "Unable to log in" unless sid
    @sid = sid
  end

  def add_document(content:, filename:, title:, author_last_name:,
                   author_first_name:, folder_id:)
    b64_document = XMLRPC::Base64.new(content)
    args = {
      folder: folder_id,
      submit_to: 1, # upload to process, not store,
      uploads: [
        {
          author_last: author_last_name,
          author_first: author_first_name,
          filename: filename,
          title: title,
          upload: b64_document
        }
      ]
    }

    call(method: 'document.add', **args)
  end

  def get_report(id:)
    call(method: 'report.get', id: id)
  end

  def get_document(id:)
    call(method: 'document.get', id: id)
  end

  private

  def unauthenticated_call(method, **args)
    @server.call(method, **args)
  end

  def sid
    @sid ||= login
  end
end
