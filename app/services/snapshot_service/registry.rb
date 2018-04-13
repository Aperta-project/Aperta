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

class SnapshotService::Registry
  class Error < ::StandardError; end
  class DuplicateRegistrationError < Error; end
  class NoSerializerRegisteredError < Error; end

  def initialize
    @registrations = {}
  end

  def empty?
    @registrations.empty?
  end

  def clear
    @registrations.clear
  end

  def serialize(klass, with:)
    existing_registration = @registrations[klass.name]
    if existing_registration
      raise DuplicateRegistrationError, "#{klass.name} is already registered to be serialized by #{existing_registration}"
    end
    @registrations[klass.name] = with.name
  end

  def serializer_for(object)
    registered_serializer_klass_string = nil

    object.class.ancestors.each do |ancestor|
      registered_serializer_klass_string = @registrations[ancestor.name]
      break if registered_serializer_klass_string
    end

    unless registered_serializer_klass_string
      raise NoSerializerRegisteredError, <<-ERROR.strip_heredoc
        No serializer found for #{object.inspect} or any of its ancestors!
        Please register your snapshot serializer in config/initializers/snapshot_serializer_registrations.rb.
      ERROR
    end

    registered_serializer_klass_string.constantize
  end
end
