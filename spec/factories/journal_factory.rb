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

FactoryGirl.define do
  factory :journal do
    sequence :name do |n|
      "Journal #{n}"
    end

    sequence :doi_journal_prefix do |n|
      "journal.SHORTJPREFIX#{n}"
    end

    sequence :doi_publisher_prefix do |n|
      "PPREFIX#{n}"
    end

    last_doi_issued "10000"

    trait(:with_paper) do
      after(:create) do |journal|
        FactoryGirl.create(:paper, journal: journal)
      end
    end

    trait(:with_default_mmt) do
      after(:create) do |journal|
        JournalFactory.setup_default_mmt(journal)
      end
    end

    trait(:with_default_task_types) do
      after(:create) do |journal|
        JournalFactory.setup_default_mmt(journal)
      end
    end

    trait(:with_roles_and_permissions) do
      after(:create) do |journal|
        JournalFactory.ensure_default_roles_and_permissions_exist(journal)
        JournalFactory.assign_hints(journal)
      end
    end

    %w(
      academic_editor creator collaborator cover_editor discussion_participant
      handling_editor internal_editor production_staff publishing_services
      staff_admin task_participant reviewer reviewer_report_owner journal_setup
    ).each do |role|
      role_method = "#{role}_role"
      trait("with_#{role_method}".to_sym) do
        after(:create) do |journal|
          journal.send(role_method) ||
            journal.send("create_#{role_method}!")
        end
      end
    end

    %w(publishing_services staff_admin).each do |role|
      trait("with_#{role}_user".to_sym) do
        after(:create) do |journal|
          FactoryGirl.create(:assignment,
                             role: journal.send("#{role}_role".to_sym),
                             user: FactoryGirl.build(:user),
                             assigned_to: journal
                            )
        end
      end
    end

    trait(:with_admin_roles) do
      with_staff_admin_role
      with_journal_setup_role
    end

    factory :journal_for_integration_tests, traits: [:with_default_mmt, :with_roles_and_permissions]

    factory :journal_with_roles_and_permissions, traits: [:with_roles_and_permissions]
    factory :journal_with_default_mmt, traits: [:with_default_mmt]
  end
end
