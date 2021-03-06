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
  In order to authorize an action on an object that the user is directly
  assigned to they must be assigned to that object with a role that has
  permissions which 'applies_to' that kind of object
DESC
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user, first_name: 'User') }
  let!(:other_user) { FactoryGirl.create(:user, first_name: 'Other User') }

  let!(:paper) { Authorizations::FakePaper.create! }
  let!(:other_paper) { Authorizations::FakePaper.create! }

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  permissions do
    permission action: 'view', applies_to: Authorizations::FakePaper.name
    permission action: 'edit', applies_to: Authorizations::FakePaper.name
    permission action: 'whatever', applies_to: Authorizations::FakePaper.name

    permission action: 'view', applies_to: 'SomethingThatIsNotAPaper'
    permission action: 'edit', applies_to: 'SomethingThatIsNotAPaper'
    permission action: 'whatever', applies_to: 'SomethingThatIsNotAPaper'
  end

  role :accessing_paper do
    has_permission action: 'view', applies_to: Authorizations::FakePaper.name
    has_permission action: 'edit', applies_to: Authorizations::FakePaper.name
    has_permission \
      action: 'whatever',
      applies_to: Authorizations::FakePaper.name
  end

  role :with_no_access_to_paper do
    has_permission action: 'view', applies_to: 'SomethingThatIsNotAPaper'
    has_permission action: 'edit', applies_to: 'SomethingThatIsNotAPaper'
    has_permission action: 'whatever', applies_to: 'SomethingThatIsNotAPaper'
  end

  context <<-DESC do
    when the user is assigned to an object with a role that grants them
    permission
  DESC

    context 'and Authorizations is not configured for access' do
      before do
        Authorizations.reset_configuration
        assign_user user, to: paper, with_role: role_accessing_paper
      end

      it 'grants access implicitly to objects you are directly assigned to' do
        expect(user.can?(:view, paper)).to be(true)
        expect(user.can?(:edit, paper)).to be(true)
        expect(user.can?(:whatever, paper)).to be(true)
      end
    end

    context <<-DESC.strip_heredoc do
      and the user is assigned to an object (e.g. Paper) with a role that has
      permissions that apply to that kind of object (e.g. Paper)
    DESC
      before do
        assign_user user, to: paper, with_role: role_accessing_paper
        assign_user other_user, to: other_paper, with_role: role_accessing_paper
      end

      it <<-DESC.strip_heredoc do
        authorizes the actions for the object they are assigned to based on
        their role's permissions
      DESC
        expect(user.can?(:view, paper)).to be(true)
        expect(user.can?(:edit, paper)).to be(true)
        expect(user.can?(:whatever, paper)).to be(true)

        expect(other_user.can?(:view, other_paper)).to be(true)
        expect(other_user.can?(:edit, other_paper)).to be(true)
        expect(other_user.can?(:whatever, other_paper)).to be(true)
      end

      it <<-DESC.strip_heredoc do
        denies them access for the actions on a different object of the same
        kind (e.g. Someone else's paper)
      DESC
        expect(user.can?(:view, other_paper)).to be(false)
        expect(user.can?(:edit, other_paper)).to be(false)
        expect(user.can?(:whatever, other_paper)).to be(false)
      end
    end

    context <<-DESC.strip_heredoc do
      and the user is assigned to an object (e.g. Paper) with a role that has
      LACKS permissions for that kind of object (e.g. the role has no permission
      that applies_to Paper
    DESC
      before do
        assign_user user, to: paper, with_role: role_with_no_access_to_paper
      end

      it 'denies them access to actions on the object they are assigned' do
        expect(user.can?(:view, paper)).to be(false)
        expect(user.can?(:edit, paper)).to be(false)
        expect(user.can?(:whatever, paper)).to be(false)
      end
    end
  end
end
