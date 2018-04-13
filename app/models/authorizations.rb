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

# This seems redundant, but DO NOT REMOVE
# It is necessary to ensure that authorization configuration persists across
# rails code reloading.
require 'authorizations/configuration'

# The Authorizations module houses the authorizations sub-system. The namespace
# is in part so we can isolate the authorization bits in code and in tests.
module Authorizations
  class << self
    # Yields an Authorizations::Configuration instance
    def configure
      yield(configuration)
    end

    # Returns the current Authorizations::Configuration instance
    def configuration
      Authorizations::Configuration
    end

    # Replaces the current Authorizations::Configuration instance with pristine
    # one. Note: This is primarily used so we can run a variety of tests
    # against the authorization sub-system.
    def reset_configuration
      Authorizations::Configuration.reset
    end

    def reload_configuration
      Authorizations::Configuration.reload
    end
  end
end
