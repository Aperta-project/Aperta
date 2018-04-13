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

require 'rails_helper'
require 'support/authorization_spec_helper'

describe <<-DESC.strip_heredoc do
  It is possible for a user to get access to the same object thru multiple
  assignments. We only want to return the object once.
DESC
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user) }
  let!(:paper) { Authorizations::FakePaper.create! }
  let!(:task) { Authorizations::FakeTask.create!(fake_paper: paper) }

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  permissions do
    permission action: 'view', applies_to: Authorizations::FakeTask.name
  end

  role :with_access_to_task do
    has_permission action: 'view', applies_to: Authorizations::FakeTask.name
  end

  before do
    Authorizations.configure do |config|
      config.assignment_to(
        Authorizations::FakePaper,
        authorizes: Authorizations::FakeTask,
        via: :fake_tasks)
    end
  end

  describe 'a user with access to an object thru multiple assignments' do
    before do
      assign_user user, to: paper, with_role: role_with_access_to_task
      assign_user user, to: task, with_role: role_with_access_to_task
    end

    it 'only returns the object once (no duplicates)' do
      expect(
        user.filter_authorized(:view, Authorizations::FakeTask.all).objects
      ).to eq([task])
    end
  end
end
