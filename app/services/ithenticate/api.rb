# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'uri'
require 'xmlrpc/client'

module Ithenticate
  # Class used for interacting with the Ithenticate API
  class Api
    ITHENTICATE_CONNECTION_ERROR = 'Error connecting to the iThenticate server.'
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
      unless sid
        add_error("Unable to log in")
      end
      @sid = sid
    end

    # rubocop:disable Metrics/ParameterLists
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
            title: title.truncate(500),
            upload: b64_document
          }
        ]
      }

      response = call(method: 'document.add', **args)
      if response && response['api_status'] != 200
        add_error("Uploading #{filename} to the iThenticate resulted in an error.")
      end
      response
    end
    # rubocop:enable Metrics/ParameterLists

    def get_report(id:)
      response = call(method: 'report.get', id: id)
      ReportResponse.new(response)
    end

    def get_document(id:)
      response = call(method: 'document.get', id: id)
      DocumentResponse.new(response)
    end

    def error?
      error.present?
    end

    def error
      @error ||= {}
    end

    def error_string
      error[:documents].first[:error]
    end

    private

    def add_error(error_message)
      @error =   { documents: [error: error_message] }
    end

    def unauthenticated_call(method, **args)
      begin
        @server.call(method, **args)
      rescue
        add_error(ITHENTICATE_CONNECTION_ERROR)
      end
    end

    def sid
      @sid ||= login
    end
  end
end
