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

# Superclass for classes that look stuff up in NED
class NedConnection
  class ConnectionError < StandardError; end

  RNF_MESSAGE = "Record not found"

  def self.enabled?
    TahiEnv.ned_enabled?
  end

  private

  def search(url, params = {})
    conn.get("#{TahiEnv.ned_api_url}/#{url}", params)
  rescue Faraday::ClientError => e
    error_message = if e.response[:status] == 400
      RNF_MESSAGE
    else
      "Error connecting to #{TahiEnv.ned_api_url}/#{url}"
    end
    # copied this over from the original file, im not sure this should be
    # the third arg to raise
    raise ConnectionError, error_message, e.response[:body]
  end

  def conn
    @conn ||= Faraday.new(ssl: { verify: TahiEnv.ned_ssl_verify? }) do |faraday|
      faraday.response :json
      faraday.request :url_encoded
      faraday.use Faraday::Response::RaiseError
      faraday.adapter Faraday.default_adapter
      faraday.basic_auth(TahiEnv.ned_cas_app_id, TahiEnv.ned_cas_app_password)
    end
  end
end
