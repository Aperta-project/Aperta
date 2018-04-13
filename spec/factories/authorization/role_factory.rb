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

# Many roles are defined on the journal level. See the journal_factory
# helpers for traits that assist with setting up specific roles. They
# are typically named like "with_<role_name>_role", e.g. with_creator_role
FactoryGirl.define do
  factory :role do
    sequence(:name){ |i| "Role #{i}" }
    journal
    participates_in_papers true
    participates_in_tasks true

    trait :site_admin do
      name Role::SITE_ADMIN_ROLE
      journal { nil }
      participates_in_papers false
      participates_in_tasks false

      after(:create) do |role|
        role.ensure_permission_exists(
          Permission::WILDCARD, applies_to: System.name
        )
      end
    end

    trait :creator do
      name Role::CREATOR_ROLE
      after(:create) do |role|
        role.ensure_permission_exists(
          Permission::WILDCARD, applies_to: System.name
        )
      end
    end
  end
end
