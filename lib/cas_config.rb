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

# CasConfig is responsible for providing the configuration necessary to
# do SSO via CAS
module CasConfig
  def self.omniauth_configuration
    if TahiEnv.cas_enabled?
      {
        'enabled' => true,
        'ssl' => TahiEnv.cas_ssl?,
        'disable_ssl_verification' => !TahiEnv.cas_ssl_verify?,
        'host' => TahiEnv.cas_host,
        'port' => TahiEnv.cas_port,
        'service_validate_url' => TahiEnv.cas_service_validate_url,
        'callback_url' => TahiEnv.cas_callback_url,
        'logout_url' => TahiEnv.cas_logout_url,
        'login_url' => TahiEnv.cas_login_url
      }
    else
      { 'enabled' => false }
    end
  end
end
