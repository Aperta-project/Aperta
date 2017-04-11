require "xmlrpc/client"
require "pry"
require "nokogiri"

api_opts = {
  host: "api.ithenticate.com",
  path: "/rpc",
  username: "apertadevteam@plos.org",
  password: "", # fill this
  use_ssl: true
}

def green(msg)
  "\e[32m#{msg}\e[0m"
end

# Override call2 on the XMLRPC to do some logging
class XMLRPC::Client
  def call2(method, *args)
    request = create().methodCall(method, *args)
    puts green(">> REQUEST")
    puts ::Nokogiri::XML(request).to_xml
    data = do_rpc(request, false)
    parser().parseMethodResponse(data)
  end
end

class IthenticateApi
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

  def add_document(file_path:, author_last_name:, author_first_name:, folder_id:)
    b64_document = XMLRPC::Base64.new(File.read(file_path))
    filename = File.basename(file_path)

    args = {
      folder: folder_id,
      submit_to: 1, # upload to process, not store,
      uploads: [
        {
          author_last: author_last_name,
          author_first: author_first_name,
          filename: filename,
          title: filename,
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
    param = @server.call(method, **args)
    puts green("<< RESPONSE")
    puts param
    param
  end

  def sid
    @sid ||= login
  end
end

api = IthenticateApi.new(api_opts)
api.login
api.get_document(id: 28637223)

__END__
api.add_document(
  file_path: '/Users/jlabarba/Downloads/Hotez-NTDs_2_0_shifting_policy_landscape_PLOS_NTDs_figs_extracted_for_submish.docx',
  author_first_name: 'turtle',
  author_last_name: 'expert',
  folder_id: 921380
)

