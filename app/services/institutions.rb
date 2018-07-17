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

require 'singleton'

class Institutions < NedConnection
  include Singleton

  PREDEFINED_INSTITUTIONS = [
    { 'name' => 'Clown College USA' },
    { 'name' => 'Hollywood Upstairs Medical School' },
    { 'name' => 'Hollywood Upstairs Clown College' }
  ].freeze

  def matching_institutions(query)
    if TahiEnv.ned_enabled?
      search('institutionsearch', substring: query).body
    else
      search_predefined query
    end
  end

  private

  def search_predefined(query)
    PREDEFINED_INSTITUTIONS.select { |i| i['name'].downcase.match(query.downcase) }
  end
end
