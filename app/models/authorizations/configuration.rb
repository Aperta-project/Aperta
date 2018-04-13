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

module Authorizations
  # An Authorizations::Configuration houses the individual Authorization(s)
  # being used to configure the authorization sub-system.
  module Configuration
    extend self

    # 'authorizations' returns the collection of authorization(s) that have \
    # been configured
    attr_accessor :authorizations, :filters

    # Creates an authorization thru the given assignment_to object and
    # options.
    def assignment_to(assignment_to, authorizes:, via:)
      @authorizations ||= []
      @authorizations << Authorizations::Authorization.new(
        assignment_to: assignment_to,
        authorizes: authorizes,
        via: via
      )
    end

    def filter(klass, column_name, &block)
      @filters ||= []
      @filters << Authorizations::Filter.new(
        klass: klass,
        column_name: column_name,
        block: block
      )
    end

    # Clears out any currently configured Authorizations.
    def reset
      @authorizations = []
      @filters = []
    end

    # Reloads the application's default Authorizations from
    # config/initializers/z_authorizations.rb
    def reload
      reset
      load 'config/initializers/z_authorizations.rb'
    end
  end
end
