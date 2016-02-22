require 'rails_helper'

describe QuestionAttachmentsPolicy do
  let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:task) { FactoryGirl.create(:task, paper: paper) }
  let(:user) { FactoryGirl.create(:user) }
  let(:nested_question_answer) { FactoryGirl.create(:nested_question_answer, owner: task) }
  let(:question_attachment) do
    FactoryGirl.create(:question_attachment,
                       nested_question_answer: nested_question_answer)
  end
  let(:policy) do
    QuestionAttachmentsPolicy.new(current_user: user,
                                  resource: question_attachment)
  end

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
        old_roles: [ FactoryGirl.create(:old_role, :admin, journal: journal), ],
      )
    end

    include_examples "person who can manage question attachments"
  end

  context "user no old_role" do
    include_examples "person who cannot manage question attachments"
  end

  context "user with old_role on different journal" do
    let(:other_journal) do
      FactoryGirl.create(:journal, :with_roles_and_permissions)
    end
    let(:user) do
      FactoryGirl.create(
        :user,
        old_roles: [ FactoryGirl.create(:old_role, :admin, journal: other_journal) ],
      )
      end

    include_examples "person who cannot manage question attachments"
  end
end
