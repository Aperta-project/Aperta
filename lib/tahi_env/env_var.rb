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

require File.dirname(__FILE__) + '/../tahi_env'

class TahiEnv
  class EnvVar
    attr_reader :key, :default_value, :additional_details

    def initialize(key, type = nil, default: nil, additional_details: nil)
      @key = key.to_s
      @type = type
      @default_value = default
      @additional_details = additional_details
    end

    def ==(other)
      other.is_a?(self.class) &&
        other.key == key
    end

    def value
      if raw_value_from_env.nil?
        default_value
      elsif boolean?
        converted_boolean_value
      elsif array?
        converted_array_value
      else
        raw_value_from_env
      end
    end

    def raw_value_from_env
      ENV[@key]
    end

    def array?
      @type == :array
    end

    def boolean?
      @type == :boolean
    end

    def to_s
      msg = "Environment Variable: #{key}"
      msg << " (#{additional_details})" if additional_details
      msg
    end

    private

    def converted_array_value
      # This is used to convert a string that contains
      # a list of string into a Ruby array object
      raw_value_from_env.split(' ')
    end

    def converted_boolean_value
      ['true', '1'].include?(raw_value_from_env.downcase)
    end
  end
end
