require 'rails_helper'

describe QuestionAttachmentsPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }
  let(:task) { FactoryGirl.create(:task, phase: phase) }
  let(:user) { FactoryGirl.create(:user) }
  let(:nested_question_answer) { FactoryGirl.create(:nested_question_answer, owner: task) }
  let(:question_attachment) { FactoryGirl.create(:question_attachment, question: nested_question_answer) }
  let(:policy) { QuestionAttachmentsPolicy.new(current_user: user, resource: question_attachment) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }
    include_examples "person who can manage question attachments"
  end

  context "paper collaborator" do
    let!(:paper_role) { create(:paper_role, :collaborator, user: user, paper: paper) }

    before do
      allow(task).to receive(:submission_task?).and_return true
    end
    include_examples "person who can manage question attachments"

    context "on a non metadata task" do
      before do
        allow(task).to receive(:submission_task?).and_return false
      end
      include_examples "person who cannot manage question attachments"
    end
  end

  context "user with can_view_all_manuscript_managers on this journal" do
    let(:user) do
      FactoryGirl.create(
        :user,
        roles: [ FactoryGirl.create(:role, :admin, journal: journal), ],
      )
    end

    include_examples "person who can manage question attachments"
  end

  context "user no role" do
    include_examples "person who cannot manage question attachments"
  end

  context "user with role on different journal" do
    let(:other_journal) { FactoryGirl.create(:journal) }
    let(:user) do
      FactoryGirl.create(
        :user,
        roles: [ FactoryGirl.create(:role, :admin, journal: other_journal) ],
      )
      end

    include_examples "person who cannot manage question attachments"
  end
end
