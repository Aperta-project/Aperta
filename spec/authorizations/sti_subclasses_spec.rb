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
  In order to authorize an action on an object that the user is not
  directly assigned to the Authorization sub-system needs to be told what
  association methods could be used to look up that object.
DESC
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user) }
  let!(:paper) { Authorizations::FakePaper.create! }
  let!(:generic_task) { Authorizations::FakeTask.create!(fake_paper: paper) }
  let!(:specialized_task) { Authorizations::SpecializedFakeTask.create!(fake_paper: paper) }
  let!(:even_more_specialized_task) { Authorizations::EvenMoreSpecializedFakeTask.create!(fake_paper: paper) }

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  after do
    Authorizations.reset_configuration
  end

  context 'when you are assigned to a descendant' do
    permissions do
      permission action: 'view', applies_to: Authorizations::FakeTask.name
    end

    role :for_viewing do
      has_permission action: 'view', applies_to: Authorizations::FakeTask.name
    end

    before do
      assign_user user, to: specialized_task, with_role: role_for_viewing
    end

    it 'grants access to the descendant the user is assigned to' do
      expect(user.can?(:view, specialized_task)).to be(true)
    end
  end

  context 'when you have permissions to an ancestor' do
    permissions do
      permission action: 'view', applies_to: Authorizations::FakeTask.name
    end

    role :for_viewing do
      has_permission action: 'view', applies_to: Authorizations::FakeTask.name
    end

    before do
      Authorizations.configure do |config|
        config.assignment_to(
          Authorizations::FakePaper,
          authorizes: Authorizations::FakeTask,
          via: :fake_tasks
        )
      end

      assign_user user, to: paper, with_role: role_for_viewing
    end

    it 'grants access to a subclass' do
      expect(user.can?(:view, specialized_task)).to be(true)
    end

    it 'grants access to a descendant (subclass of a subclass and so on)' do
      expect(user.can?(:view, even_more_specialized_task)).to be(true)
    end

    it 'includes the descendants when filtering for authorization of the parent class' do
      expect(
        user.filter_authorized(:view, Authorizations::FakeTask.all, participations_only: false).objects
      ).to contain_exactly(generic_task, specialized_task, even_more_specialized_task)
    end

    it 'includes the only subclass objects and its descendants when filtering for authorization of the subclass' do
      expect(
        user.filter_authorized(:view, Authorizations::SpecializedFakeTask.all, participations_only: false).objects
      ).to contain_exactly(specialized_task, even_more_specialized_task)

      expect(
        user.filter_authorized(:view, Authorizations::EvenMoreSpecializedFakeTask.all, participations_only: false).objects
      ).to contain_exactly(even_more_specialized_task)
    end
  end

  context 'when you have permissions to a descendant' do
    permissions do
      permission action: 'view', applies_to: Authorizations::SpecializedFakeTask.name
    end

    role :for_viewing do
      has_permission action: 'view', applies_to: Authorizations::SpecializedFakeTask.name
    end

    before do
      Authorizations.configure do |config|
        config.assignment_to(
          Authorizations::FakePaper,
          authorizes: Authorizations::FakeTask,
          via: :fake_tasks
        )
      end

      assign_user user, to: paper, with_role: role_for_viewing
    end

    it 'grants access to the descendant' do
      expect(user.can?(:view, specialized_task)).to be(true)
    end

    it 'grants access to a descendant (subclass of a subclass and so on)' do
      expect(user.can?(:view, even_more_specialized_task)).to be(true)
    end

    it 'does not grant access on the ancestor' do
      expect(user.can?(:view, generic_task)).to be(false)
    end

    it 'does not include impermissible ancestors when filtering for authorization of the parent class' do
      expect(
        user.filter_authorized(:view, Authorizations::FakeTask.all, participations_only: false).objects
      ).to_not include(generic_task)
    end

    it 'includes the only subclass objects and its descendants when filtering for authorization of the subclass' do
      expect(
        user.filter_authorized(:view, Authorizations::SpecializedFakeTask.all, participations_only: false).objects
      ).to contain_exactly(specialized_task, even_more_specialized_task)

      expect(
        user.filter_authorized(:view, Authorizations::EvenMoreSpecializedFakeTask.all, participations_only: false).objects
      ).to contain_exactly(even_more_specialized_task)
    end
  end
end
