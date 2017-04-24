require 'rails_helper'

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
  end
end
