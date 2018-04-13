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

# This class provides the attribute part of an EAV model
# (https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model)
#
# It allows defining any number of named attributes (of different types)
# attached to an entity without changing the database schema. The names and
# types of the attributes are managed in code: see Attributable.
class EntityAttribute < ActiveRecord::Base
  include ViewableModel
  include XmlSerializable

  # The entity to which this attribute belongs.
  belongs_to :entity, inverse_of: :entity_attributes, polymorphic: true
  # Ensure there is only a single attribute for each name on a given entity.
  validates :name, presence: true, uniqueness: { scope: :entity }

  def value
    case value_type
    when 'string'  then string_value
    when 'boolean' then boolean_value?
    when 'integer' then integer_value
    when 'json'    then json_value
    end
  end

  def value=(content)
    case value_type
    when 'string'  then self.string_value  = content
    when 'boolean' then self.boolean_value = content
    when 'integer' then self.integer_value = content
    when 'json'    then self.json_value    = content
    end
  end
end
