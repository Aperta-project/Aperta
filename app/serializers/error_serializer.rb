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

# ErrorSerializer is intended to be used for allowing controllers to not
# only respond with an HTTP error status code, but to include a useful
# body which contains information about the error.
class ErrorSerializer < AuthzSerializer
  # Provide a model for our error, but hide its details at this time since
  # it's not used anywhere outside of this serializer.
  #
  # https://github.com/rails-api/active_model_serializers/blob/master/docs/howto/serialize_poro.md
  class Error
    alias :read_attribute_for_serialization :send

    attr_accessor :message

    def initialize(message:)
      @message = message
    end

    def self.model_name
      @_model_name ||= ActiveModel::Name.new(self)
    end
  end

  attributes :message

  # attributes is expected to contain attributes that the Error model
  # above defines, e.g. :message
  def initialize(attributes, *args)
    model = Error.new(attributes)
    super(model, *args)
  end
end
