require 'rails_helper'

module PlosBilling
  describe BillingTask do
    let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
    let(:billing_task) do
      ::PlosBilling::BillingTask.create!(
        completed: true,
        paper: paper,
        phase: paper.phases.first,
        title: "Billing",
        old_role: "author"
      )
    end

    describe '.create' do
      it "creates it" do
        expect(billing_task).to_not be_nil
      end
    end

    describe '#active_model_serializer' do
      it 'has the proper serializer' do
        expect(billing_task.active_model_serializer).to eq PlosBilling::TaskSerializer
      end
    end
  end

  describe "Permissions" do
    let(:journal) { create :journal, :with_roles_and_permissions }
    let(:editor) { create :user }
    let(:author) { create :user }
    let(:paper) do
      create :paper, :with_tasks, journal: journal, creator: author
    end
    let(:billing_task) do
      TaskFactory.create(
        ::PlosBilling::BillingTask,
        completed: true,
        paper: paper,
        phase: paper.phases.first,
        title: "Billing",
        old_role: "author"
      )
    end

    before do
      assign_journal_role journal, editor, :editor
    end

    specify "a staff editor can not view the billing card" do
      expect(author.can? :view, billing_task).to eq true
      expect(editor.can? :view, billing_task).to eq false
    end
  end
end
