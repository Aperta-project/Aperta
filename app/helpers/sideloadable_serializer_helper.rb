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

# This helper method makes it easy to side load permissions (or other
# resources) into the JSON response.
#
# Usage:
#   side_load :example_method_to_side_load
#
#   # The key in the sideloaded JSON will match method name
#   def example_method_to_side_load
#      return {example_property: 'example_key'}
#   end
#
#  JSON Returned from serializer:
#  {example_method_to_side_load: {example_property: 'example_key'} }

module SideloadableSerializerHelper
  def self.included(base)
    base.extend ClassMethods
  end

  # Included class methods
  module ClassMethods
    def side_load(side_load_source)
      to_side_load(side_load_source)
    end

    def to_side_load(side_load_source = nil)
      @to_side_load ||= []
      if side_load_source
        @to_side_load << side_load_source
        return nil
      else
        return @to_side_load
      end
    end
  end

  def as_json(*args)
    hash = super(*args)
    hash.merge(side_loader)
  end

  def side_loader
    side_loading = self.class.to_side_load
    result = {}
    side_loading.each do |method|
      result[method] = send(method).as_json
    end
    result
  end
end
