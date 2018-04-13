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

# rubocop:disable Style/PredicateName
# rubocop:disable Metrics/AbcSize
#
# This concern enables the entity part of an EAV model
# (https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model)
#
# See CardContent model for an example of its use.
# See EntityAttribute for the attributes.
module Attributable
  extend ActiveSupport::Concern

  included do
    has_many :entity_attributes, dependent: :destroy, inverse_of: :entity, as: :entity

    def inspect
      super.tap do |base|
        # Inspect strings end in >. We will chop of the end and insert some
        # stuff in between.
        base.chomp!(">")
        entity_attributes.each do |a|
          base << ", *#{a.name}: #{a.value}"
        end
        base << ">"
      end
    end
  end

  module ClassMethods
    def has_attributes(types)
      types.each do |type, names|
        names.each do |name|
          getter = "#{name}_attribute".to_sym
          setter = "#{name}_attribute=".to_sym

          has_one getter, -> { where(name: name) }, class_name: EntityAttribute, as: :entity

          define_method(name) do
            if send(:entity_attributes).loaded?
              send(:entity_attributes).find { |a| a.name == name }.try(:value)
            else
              send(getter).try(:value)
            end
          end

          define_method("#{name}=") do |new_value|
            entity_attribute = send(getter) || send(:entity_attributes).new(name: name, value_type: type)

            # false.presence => nil, work around this
            entity_attribute.value = new_value == false ? false : new_value.presence

            send(setter, entity_attribute)
          end
        end
      end
    end
  end
end
