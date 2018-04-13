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

class Role < ActiveRecord::Base
  include ViewableModel
  belongs_to :journal
  has_and_belongs_to_many :permissions
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments

  ACADEMIC_EDITOR_ROLE = 'Academic Editor'.freeze
  BILLING_ROLE = 'Billing Staff'.freeze
  COLLABORATOR_ROLE = 'Collaborator'.freeze
  COVER_EDITOR_ROLE = 'Cover Editor'.freeze
  CREATOR_ROLE = 'Creator'.freeze
  DISCUSSION_PARTICIPANT = 'Discussion Participant'.freeze
  FREELANCE_EDITOR_ROLE = 'Freelance Editor'.freeze
  HANDLING_EDITOR_ROLE = 'Handling Editor'.freeze
  INTERNAL_EDITOR_ROLE = 'Internal Editor'.freeze
  PRODUCTION_STAFF_ROLE = 'Production Staff'.freeze
  PUBLISHING_SERVICES_ROLE = 'Publishing Services'.freeze
  REVIEWER_ROLE = 'Reviewer'.freeze
  SITE_ADMIN_ROLE = 'Site Admin'.freeze
  JOURNAL_SETUP_ROLE = 'Journal Setup Admin'.freeze
  STAFF_ADMIN_ROLE = 'Staff Admin'.freeze
  TASK_PARTICIPANT_ROLE = 'Participant'.freeze
  USER_ROLE = 'User'.freeze
  REVIEWER_REPORT_OWNER_ROLE = 'Reviewer Report Owner'.freeze

  # These roles (user, discussion topic, task) are automatically
  # assigned by the system
  USER_ROLES = [USER_ROLE].freeze

  DISCUSSION_TOPIC_ROLES = [DISCUSSION_PARTICIPANT].freeze

  TASK_ROLES = [
    REVIEWER_REPORT_OWNER_ROLE,
    TASK_PARTICIPANT_ROLE
  ].freeze

  # Paper and Journal roles are set explicitly
  PAPER_ROLES = [
    ACADEMIC_EDITOR_ROLE,
    COLLABORATOR_ROLE,
    COVER_EDITOR_ROLE,
    CREATOR_ROLE,
    HANDLING_EDITOR_ROLE,
    REVIEWER_ROLE
  ].freeze

  JOURNAL_ROLES = [
    FREELANCE_EDITOR_ROLE,
    INTERNAL_EDITOR_ROLE,
    PRODUCTION_STAFF_ROLE,
    PUBLISHING_SERVICES_ROLE,
    STAFF_ADMIN_ROLE,
    JOURNAL_SETUP_ROLE
  ].freeze

  def user_can_view?(_check_user)
    true
  end

  def self.user_role
    find_by(name: Role::USER_ROLE, journal: nil)
  end

  def self.site_admin_role
    find_by(name: Role::SITE_ADMIN_ROLE, journal: nil)
  end

  def self.ensure_exists(*args, &blk)
    Authorizations::RoleDefinition.ensure_exists(*args, &blk)
  end

  def ensure_permission_exists(action, applies_to:, role: nil, states: [Permission::WILDCARD])
    Permission.ensure_exists(
      action,
      applies_to: applies_to,
      role: self,
      states: states
    )
  end
end
