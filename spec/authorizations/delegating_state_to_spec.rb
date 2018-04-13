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

describe "Permission states can be delegated to a model's association" do
  include AuthorizationSpecHelper

  after do
    Authorizations.reset_configuration
  end

  let!(:user) { FactoryGirl.create(:user) }
  let!(:paper) { FactoryGirl.create(:paper) }
  let!(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }

  permissions do
    permission action: 'edit', applies_to: Task.name, states: Paper::EDITABLE_STATES
  end

  role :for_viewing do
    has_permission action: 'edit', applies_to: Task.name, states: Paper::EDITABLE_STATES
  end

  context <<-DESC do
    Task delegates permission states to its associated paper
    and the user is assigned a task
  DESC
    before do
      assign_user user, to: task, with_role: role_for_viewing
    end

    context 'the paper is in an editable state' do
      before do
        paper.update_column(:publishing_state, Paper::EDITABLE_STATES.first)
      end

      it 'allows the user edit the task' do
        expect(user.can?(:edit, task)).to be(true)
      end
    end
    context 'the paper is in an uneditable state' do
      before do
        paper.update_column(:publishing_state, Paper::UNEDITABLE_STATES.first)
      end
      it 'does not allow the user edit the task' do
        expect(user.can?(:edit, task)).to be(false)
      end
    end
  end
end
