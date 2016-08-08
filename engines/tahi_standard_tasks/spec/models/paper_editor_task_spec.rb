require 'rails_helper'

describe TahiStandardTasks::PaperEditorTask do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper_with_phases, journal: journal) }
  let!(:author) { FactoryGirl.create(:author, paper: paper) }

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
    it_behaves_like '<Task class>.restore_defaults update old_role to the default'
  end

  describe "#invitation_invited" do
    let!(:task) do
      TahiStandardTasks::PaperEditorTask.create!({
        paper: paper,
        phase: paper.phases.first,
        title: "Invite Editor",
        old_role: "admin"
      })
    end
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it_behaves_like 'a task that sends out invitations',
                    invitee_role: Role::ACADEMIC_EDITOR_ROLE

    it "notifies the invited editor" do
      expect {
        task.invitation_invited(invitation)
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :length).by(1)
    end
  end

  describe "#invitation_accepted" do
    before do
      Role.ensure_exists(Role::ACADEMIC_EDITOR_ROLE, journal: journal)
    end

    let!(:task) do
      TahiStandardTasks::PaperEditorTask.create!({
        paper: paper,
        phase: paper.phases.first,
        title: "Invite Editor",
        old_role: "admin"
      })
    end

    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it 'adds the invitee as an Academic Editor on the paper' do
      invitation.accept!
      expect(paper.academic_editors).to include(invitation.invitee)
    end
  end

  describe '#invitation_template' do
    let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }
    let(:paper) do
      FactoryGirl.create(:paper_with_phases, :with_creator, journal: journal)
    end

    subject(:invitation_template) { task.invitation_template }
    let!(:task) do
      TahiStandardTasks::PaperEditorTask.create!({
        paper: paper,
        phase: paper.phases.first,
        title: 'Invite Editor',
        old_role: 'admin'
      })
    end

    it 'has a salutation' do
      expect(invitation_template.salutation).to eq 'Dear Dr. [EDITOR NAME],'
    end

    it 'has a letter body' do
      expect(invitation_template.body).to be
    end

    describe 'the letter body' do
      it 'includes the manuscript title' do
        expect(invitation_template.body).to include \
          paper.display_title(sanitized: false)
      end

      it 'includes the journal name' do
        expect(invitation_template.body).to include journal.name
      end

      it 'includes the paper creator name' do
        expect(invitation_template.body).to include paper.creator.full_name
      end

      it 'includes the authors list' do
        expect(invitation_template.body)
          .to include(TahiStandardTasks::AuthorsList.authors_list(paper))
      end

      it 'includes the paper abstract' do
        expect(invitation_template.body).to include paper.abstract
      end

      it 'includes the dashboard_url' do
        expect(invitation_template.body).to include \
          ::Tahi::Application.routes.url_helpers.root_url
      end
    end
  end
end
