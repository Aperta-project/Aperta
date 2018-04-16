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
  # RoleDefinition represents the definition a role. It is used for building
  # up role definitions that can be imported with Authorizations::RoleImporter
  # efficiently.
  class RoleDefinition
    attr_accessor :name, :journal, :participates_in, :permission_definitions

    def self.ensure_exists(name, journal: nil, participates_in: [], &block)
      role_definition = new(
        name: name,
        journal: journal,
        participates_in: participates_in
      )
      yield role_definition if block
      role_definition.ensure_exists!
    end

    def initialize(name:, journal:, participates_in: [])
      @name = name
      @journal = journal
      @participates_in = participates_in || []
      @permission_definitions = []
    end

    def ensure_exists!
      RoleImporter.new(self).import!
    end

    def ensure_permission_exists(action, applies_to:, states: [Permission::WILDCARD])
      if applies_to.is_a?(Class) && applies_to.try(:name).nil?
        Rails.logger.warn <<-WARN
          Skipping #ensure_permission_exists for a class without a name. If
          this is in the test environment it can be safely ignored as this
          happens when anonymous subclasses are created for tests.
        WARN
      else
        @permission_definitions << PermissionDefinition.new(
          action: action.to_s,
          applies_to: (applies_to.try(:name) || applies_to),
          states: states.map(&:to_s).sort
        )
      end
    end
  end
end
