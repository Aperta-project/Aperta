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
  sequence :email do |n|
    "#{n}#{Faker::Internet.unique.email}"
  end

  sequence :username do |n|
    "testuser#{n}"
  end

  sequence :last_name do |n|
    "Smith#{n}"
  end

  sequence :first_name do |n|
    "Henry#{n}"
  end

  sequence :ned_id, 100

  factory :user do
    username
    first_name
    last_name
    email
    password 'password'
    password_confirmation 'password'
    ned_id

    trait :site_admin do
      after(:create) do |user, _evaluator|
        role = Role.site_admin_role || FactoryGirl.create(:role, :site_admin)
        user.assign_to! assigned_to: System.first_or_create!, role: role
      end
    end

    trait :with_affiliation do
      after(:create) do |user, _evaluator|
        create(:affiliation, user: user)
      end
    end

    trait :orcid do
      credentials { [create(:orcid_credential)] }
    end

    trait :cas do
      credentials { [create(:cas_credential)] }
    end
  end
end
