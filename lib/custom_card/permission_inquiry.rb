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

module CustomCard
  # The purpose of this class is to return the view and edit permissions of an existing Task.
  #
  # This is most useful when migrating a legacy Task to a custom Card and the developer wants
  # to ensure that the correct permissions are carried over.
  #
  # Usage:
  #   CustomCard::PermissionInquiry.new(legacy_class_name: "TahiStandardTasks::CoverLetterTask").legacy_permissions
  #
  # Result:
  # { view: ["Academic Editor", "Billing Staff", "Collaborator", "Cover Editor"],
  #   edit: ["Collaborator", "Cover Editor", "Creator"]}
  #
  class PermissionInquiry
    attr_reader :legacy_class_name

    def initialize(legacy_class_name:)
      @legacy_class_name = legacy_class_name
    end

    # returns hash where key is an action name and value is a list of role names with a permission with that action
    def legacy_permissions
      [:view, :edit].each_with_object({}) do |action, result|
        roles = Role.joins(:permissions).where(permissions: { action: action, applies_to: legacy_class_name }).order(:name)
        result[action] = roles.pluck(:name).uniq
      end
    end
  end
end
