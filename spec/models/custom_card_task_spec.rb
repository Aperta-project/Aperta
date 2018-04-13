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

describe CustomCardTask do
  it 'is valid with factory defaults' do
    custom_card_task = FactoryGirl.build(:custom_card_task)
    expect(custom_card_task).to be_valid
  end

  describe "permissions" do
    include AuthorizationSpecHelper

    subject(:user) { FactoryGirl.create(:user) }

    let(:paper) { FactoryGirl.create(:paper) }
    let(:task) { FactoryGirl.create(:custom_card_task, paper: paper) }
    let(:other_task) { FactoryGirl.create(:custom_card_task, paper: paper) }
    let(:card_version) { task.card_version }
    let(:card) { card_version.card }

    before(:all) do
      Authorizations::Configuration.reload
    end

    context "with a role that can view all tasks but can only edit one" do
      permissions do |context|
        permission(
          action: 'edit',
          applies_to: Task.name,
          filter_by_card_id: context.card.id
        )
        permission(
          action: 'view',
          applies_to: Task.name
        )
      end

      role :with_access do |context|
        has_permission(
          action: 'edit',
          applies_to: Task.name,
          filter_by_card_id: context.card.id
        )
        has_permission(
          action: 'view',
          applies_to: Task.name
        )
      end

      describe "when a user is assigned to that role on a paper" do
        before(:each) do
          assign_user user, to: paper, with_role: role_with_access
        end

        it "the user can view all tasks" do
          expect(user).to be_able_to(:view, task, other_task)
        end

        it "the user can edit one task, but not another" do
          expect(user).to be_able_to(:edit, task)
          expect(user).not_to be_able_to(:edit, other_task)
        end
      end
    end

    context 'with a role than can view a card version' do
      permissions do |context|
        permission(
          action: 'view',
          applies_to: CardVersion.name,
          filter_by_card_id: context.card.id
        )
      end

      role :with_access do |context|
        has_permission(
          action: 'view',
          applies_to: CardVersion.name,
          filter_by_card_id: context.card.id
        )
      end

      describe "when a user is assigned to that role on a paper" do
        before(:each) do
          assign_user user, to: paper, with_role: role_with_access
        end

        it "the user can view the card version" do
          expect(user).to be_able_to(:view, card_version)
        end

        it "the user can not view another card version" do
          pending("APERTA-10226")
          expect(user).not_to be_able_to(:view, other_task.card_version)
        end
      end
    end
  end
end
