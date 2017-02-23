require 'rails_helper'
include ClientRouteHelper

describe UserMailer, redis: true do
  let(:app_name) { 'TEST-APP-NAME' }

  before do
    allow_any_instance_of(MailerHelper).to receive(:app_name).and_return app_name
    allow_any_instance_of(TemplateHelper).to receive(:app_name).and_return app_name
  end

  shared_examples_for "invitor is not available" do
    before { expect(invitee).to receive(:id).and_return(nil) }

    it "anonymizes the invitor" do
      expect(email.body).to match(/Someone/)
    end
  end

  shared_examples_for "recipient without email address" do
    before do
      invitee.tap do |user|
        user.email = ""
        user.save(validate: false)
      end
    end
    it "anonymizes the invitor" do
      expect(email.perform_deliveries).to eq(false)
    end
  end

  describe '#add_collaborator' do
    let(:invitor) { FactoryGirl.create(:user) }
    let(:invitee) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:email) { UserMailer.add_collaborator(invitor.id, invitee.id, paper.id) }

    it_behaves_like "invitor is not available"
    it_behaves_like "recipient without email address"

    it 'sends the email to the invitees email address with correct subject' do
      expect(email.to).to contain_exactly(invitee.email)
      expect(email.subject).to eq "You've been added as a collaborator to the manuscript, \"#{paper.display_title}\""
    end

    it 'tells the user they have been added as a collaborator' do
      expect(email.body).to match(/added you as a collaborator/)
    end
  end

  describe '#add_participant' do
    let(:invitor) { FactoryGirl.create(:user) }
    let(:invitee) { FactoryGirl.create(:user) }
    let(:task) { FactoryGirl.create(:ad_hoc_task) }
    let(:email) { UserMailer.add_participant(invitor.id, invitee.id, task.id) }

    it_behaves_like "invitor is not available"
    it_behaves_like "recipient without email address"

    it 'sends the email to the invitees email address with the correct subject' do
      expect(email.to).to contain_exactly(invitee.email)
      expect(email.subject).to eq "You've been added to a conversation on the manuscript, \"#{task.paper.display_title}\""
    end

    it 'tells the user they have been added as a collaborator' do
      expect(email.body).to match(/added you to a conversation/)
    end
  end

  describe '#add_editor_to_editors_discussion' do
    let(:invitee) { FactoryGirl.create(:user) }
    let(:task) { FactoryGirl.create(:editors_discussion_task) }
    let(:email) { UserMailer.add_editor_to_editors_discussion(invitee.id, task.id) }
    let(:abstract) { 'Tongue twister tong t.' }

    before { task.paper.update! body: "Dragon red blue green yellow." }

    context 'when the paper has an abstract' do
      it 'sends a specific email to the editor invitee' do
        task.paper.update! abstract: abstract
        expect(email.subject).to eq "You've been invited to the editor discussion for the manuscript, \"#{task.paper.display_title}\""
        expect(email.body).to include 'View Discussion'
        expect(email.body).to include abstract
      end
    end

    context 'when the paper has no abstract' do
      it 'sends a specific email to the editor invitee' do
        expect(email.subject).to eq "You've been invited to the editor discussion for the manuscript, \"#{task.paper.display_title}\""
        expect(email.body).to include 'View Discussion'
        expect(email.body).to_not include 'Abstract'
      end
    end
  end

  describe '#notify_mention_in_discussion' do
    let(:user)  { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:topic) { FactoryGirl.create(:discussion_topic, paper: paper) }
    let(:reply) { FactoryGirl.create(:discussion_reply) }
    let(:email) { UserMailer.notify_mention_in_discussion(user.id, topic.id, reply.id) }

    let(:sanitized_body) { 'hi foo <a class="discussion-at-mention" data-user-id="200" title="Steve Zissou">@steve</a>' }

    it 'uses the sanitized body from the reply and marks it as html_safe' do
      allow(DiscussionReply).to receive(:find).and_return reply
      allow(reply).to receive(:sanitized_body).and_return sanitized_body
      expect(sanitized_body).to receive(:html_safe).and_return sanitized_body.html_safe
      expect(email.body).to include sanitized_body
    end
  end

  describe '#mention_collaborator' do
    let(:invitee) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }
    let(:comment) { FactoryGirl.create(:comment, task: task) }

    let(:email) { UserMailer.mention_collaborator(comment.id, invitee.id) }

    it_behaves_like "recipient without email address"

    it 'sends the email to the mentioned user with the correct subject' do
      expect(email.to).to contain_exactly(invitee.email)
      expect(email.subject).to eq "You've been mentioned on the manuscript, \"#{task.paper.display_title}\""
    end

    it 'tells the user they have been mentioned' do
      expect(email.body).to include "You've been mentioned by #{comment.commenter.full_name}"
      expect(email.body).to include paper.display_title
      expect(email.body).to include paper.tasks.first.title
      expect(email.body).to include comment.body
      expect(email.body).to include client_paper_task_url(paper, paper.tasks.first)
    end
  end

  describe '#notify_creator_of_paper_submission' do
    let(:paper) do
      FactoryGirl.create(:paper, :with_creator, :submitted)
    end
    let(:author) { paper.creator }
    let(:email) { UserMailer.notify_creator_of_paper_submission(paper.id) }

    it "sends the email to the paper's creator with the correct subject" do
      expect(email.to).to contain_exactly(author.email)
      expect(email.subject).to eq "Thank you for submitting your manuscript to #{paper.journal.name}"
    end

    it "emails the creator user they have been mentioned" do
      expect(email.body).to include "Thank you for submitting your manuscript"
      expect(email.body).to include paper.title
      expect(email.body).to include paper.journal.name
    end
  end

  describe '#notify_coauthor_of_paper_submission' do
    let(:journal) do
      FactoryGirl.create(:journal, staff_email: journal_staff_email)
    end

    let(:paper) do
      FactoryGirl.create(:paper, :with_creator, :submitted, journal: journal)
    end

    let!(:author_1) do
      FactoryGirl.create(:author,
        email: paper.creator.email,
        first_name: paper.creator.first_name,
        last_name: paper.creator.last_name,
        paper: paper)
    end

    let!(:author_2) do
      FactoryGirl.create(:group_author,
        paper: paper)
    end

    let!(:author_3) do
      FactoryGirl.create(:author,
        email: Faker::Internet.email,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        paper: paper)
    end

    let(:journal_staff_email) { 'staffemail@example.com' }

    let(:email_1) do
      UserMailer.notify_coauthor_of_paper_submission(paper.id, author_2.id, "GroupAuthor")
    end

    let(:authors_full_names) do
      paper.all_authors.map(&:full_name)
    end

    it "sends the email to a group coauthor and list all authors" do
      expect(email_1.to).to contain_exactly(author_2.email)
      expect(email_1.subject).to eq("Authorship Confirmation of Manuscript Submitted to #{paper.journal.name}")
      expect(email_1.body).to include(paper.title)
      expect(email_1.body).to include_as_escaped_html("#{author_2.full_name},")
      expect(email_1.body).not_to include_as_escaped_html("Dr #{author_2.full_name},")
      authors_full_names.each do |author_full_name|
        expect(email_1.body).to include_as_escaped_html(author_full_name)
      end
    end

    it "has a reply-to header set to the journal staff email" do
      expect(email_1.reply_to).to include(journal_staff_email)
    end

    it "has a link to confirm authorship" do
      expect(email_1.body).to include("Confirm Authorship")
      expect(email_1.body).to include("co_authors_token/#{author_2.token}")
    end

    it "has a mailto: link to refute authorship" do
      expect(email_1.body).to include("Reply to this email to refute authorship")
      expect(email_1.body).to include("mailto:#{journal_staff_email}?subject=Authorship Confirmation of Manuscript Submitted to #{paper.journal.name}")
    end

    let(:email_2) do
      UserMailer.notify_coauthor_of_paper_submission(paper.id, author_3.id, "Author")
    end

    it "sends the email to an individual coauthor and lists all the authors" do
      expect(email_2.to).to contain_exactly(author_3.email)
      expect(email_2.subject).to eq("Authorship Confirmation of Manuscript Submitted to #{paper.journal.name}")
      expect(email_2.body).to include(paper.title)
      expect(email_2.body).to include_as_escaped_html("Dr #{author_3.last_name},")

      authors_full_names.each do |author_full_name|
        expect(email_2.body).to include_as_escaped_html(author_full_name)
      end
    end
  end

  describe '#notify_creator_of_initial_submission' do
    let(:paper) do
      FactoryGirl.create(:paper, :with_creator, :initially_submitted)
    end
    let(:author) { paper.creator }
    let(:email) { UserMailer.notify_creator_of_initial_submission(paper.id) }

    it "sends the email to the paper's creator with the correct subject" do
      expect(email.to).to contain_exactly(author.email)
      expect(email.subject).to eq "Thank you for submitting to #{paper.journal.name}"
    end

    it "includes key points in the text" do
      expect(email.body).to include "whether your manuscript meets the criteria"
      expect(email.body).to include paper.title
      expect(email.body).to include paper.journal.name
    end
  end

  describe '#notify_staff_of_paper_withdrawal' do
    include EmailSpec::Helpers
    include EmailSpec::Matchers

    subject(:email) { UserMailer.notify_staff_of_paper_withdrawal(paper.id) }
    let(:journal) do
      FactoryGirl.create(
        :journal,
        :with_creator_role,
        :with_academic_editor_role,
        :with_cover_editor_role,
        :with_handling_editor_role,
        :with_reviewer_role,
        staff_email: 'plos-people@example.com'
      )
    end
    let(:paper) do
      FactoryGirl.create(
        :paper,
        :with_creator,
        :submitted,
        journal: journal
      )
    end
    let!(:withdrawn_by_user) { FactoryGirl.create(:user) }

    before do
      paper.withdrawals.create!(
        reason: 'Needs more work',
        withdrawn_by_user_id: withdrawn_by_user.id,
        previous_publishing_state: 'unsubmitted'
      )
    end

    it "sends the email to the staff email for the paper's journal" do
      expect(email.to).to contain_exactly('plos-people@example.com')
      expect(email.subject).to eq "#{paper.doi} - Manuscript Withdrawn"
    end

    it 'includes a link to the withdrawn paper' do
      expect(links_in_email(email)).to include client_paper_url(paper)
    end

    context 'and the journal does not have a staff email configured' do
      before { journal.update(staff_email: nil) }

      it 'raises a DeliveryError' do
        error_message = [
          "Journal (id=#{journal.id} name=#{journal.name}) has no staff email configured.",
          "The notify_staff_of_paper_withdrawal email cannot be sent.\n"
        ].join("\n")
        expect do
          email.to
        end.to raise_error(UserMailer::DeliveryError, error_message)
      end
    end

    it 'includes important messaging about the withdrawal in the body' do
      expect(email).to have_body_text "This manuscript has been withdrawn by #{withdrawn_by_user.full_name}"
      expect(email).to have_body_text /MS #:.*#{Regexp.escape(paper.doi)}/
      expect(email).to have_body_text /Title:.*#{Regexp.escape(paper.title)}/
      expect(email).to have_body_text paper.latest_withdrawal.reason
    end

    it 'includes the paper creator in the body' do
      expect(email).to have_body_text /Author:.*#{Regexp.escape(paper.creator.full_name)}.*\(#{Regexp.escape(paper.creator.email)}\)/
    end

    context 'and there are no editors or reviewers assigned' do
      it 'includes this infromation in the body' do
        expect(email).to have_body_text /Academic Editor:.*No assigned academic editors/
        expect(email).to have_body_text /Cover Editor:.*No assigned cover editors/
        expect(email).to have_body_text /Handling Editor:.*No assigned handling editors/
        expect(email).to have_body_text /Reviewer:.*No assigned reviewers/
      end
    end

    context 'and there is one of each kind of editor and reviewer assigned' do
      let(:academic_editor) { FactoryGirl.create(:user) }
      let(:cover_editor) { FactoryGirl.create(:user) }
      let(:handling_editor) { FactoryGirl.create(:user) }
      let(:reviewer) { FactoryGirl.create(:user) }

      before do
        academic_editor.assign_to!(assigned_to: paper, role: journal.academic_editor_role)
        cover_editor.assign_to!(assigned_to: paper, role: journal.cover_editor_role)
        handling_editor.assign_to!(assigned_to: paper, role: journal.handling_editor_role)
        reviewer.assign_to!(assigned_to: paper, role: journal.reviewer_role)
      end

      it 'includes this infromation in the body' do
        expect(email).to have_body_text /Academic Editor:.*#{Regexp.escape(academic_editor.full_name)}.*\(#{Regexp.escape(academic_editor.email)}\)/
        expect(email).to have_body_text /Cover Editor:.*#{Regexp.escape(cover_editor.full_name)}.*\(#{Regexp.escape(cover_editor.email)}\)/
        expect(email).to have_body_text /Handling Editor:.*#{Regexp.escape(handling_editor.full_name)}.*\(#{Regexp.escape(handling_editor.email)}\)/
        expect(email).to have_body_text /Reviewer:.*#{Regexp.escape(reviewer.full_name)}.*\(#{Regexp.escape(reviewer.email)}\)/
      end
    end

    context 'and there are multiple of each kind of editor and reviewer assigned' do
      let(:academic_editor_1) { FactoryGirl.create(:user) }
      let(:academic_editor_2) { FactoryGirl.create(:user) }

      let(:cover_editor_1) { FactoryGirl.create(:user) }
      let(:cover_editor_2) { FactoryGirl.create(:user) }

      let(:handling_editor_1) { FactoryGirl.create(:user) }
      let(:handling_editor_2) { FactoryGirl.create(:user) }

      let(:reviewer_1) { FactoryGirl.create(:user) }
      let(:reviewer_2) { FactoryGirl.create(:user) }

      before do
        academic_editor_1.assign_to!(assigned_to: paper, role: journal.academic_editor_role)
        academic_editor_2.assign_to!(assigned_to: paper, role: journal.academic_editor_role)

        cover_editor_1.assign_to!(assigned_to: paper, role: journal.cover_editor_role)
        cover_editor_2.assign_to!(assigned_to: paper, role: journal.cover_editor_role)

        handling_editor_1.assign_to!(assigned_to: paper, role: journal.handling_editor_role)
        handling_editor_2.assign_to!(assigned_to: paper, role: journal.handling_editor_role)

        reviewer_1.assign_to!(assigned_to: paper, role: journal.reviewer_role)
        reviewer_2.assign_to!(assigned_to: paper, role: journal.reviewer_role)
      end

      it 'includes this infromation in the body' do
        expect(email).to have_body_text /Academic Editors:/
        expect(email).to have_body_text /#{Regexp.escape(academic_editor_1.full_name)}.*\(#{Regexp.escape(academic_editor_1.email)}\)/
        expect(email).to have_body_text /#{Regexp.escape(academic_editor_2.full_name)}.*\(#{Regexp.escape(academic_editor_2.email)}\)/

        expect(email).to have_body_text /Cover Editors:/
        expect(email).to have_body_text /#{Regexp.escape(cover_editor_1.full_name)}.*\(#{Regexp.escape(cover_editor_1.email)}\)/
        expect(email).to have_body_text /#{Regexp.escape(cover_editor_2.full_name)}.*\(#{Regexp.escape(cover_editor_2.email)}\)/

        expect(email).to have_body_text /Handling Editors:/
        expect(email).to have_body_text /#{Regexp.escape(handling_editor_1.full_name)}.*\(#{Regexp.escape(handling_editor_1.email)}\)/
        expect(email).to have_body_text /#{Regexp.escape(handling_editor_2.full_name)}.*\(#{Regexp.escape(handling_editor_2.email)}\)/

        expect(email).to have_body_text /Reviewers:/
        expect(email).to have_body_text /#{Regexp.escape(reviewer_1.full_name)}.*\(#{Regexp.escape(reviewer_1.email)}\)/
        expect(email).to have_body_text /#{Regexp.escape(reviewer_2.full_name)}.*\(#{Regexp.escape(reviewer_2.email)}\)/
      end
    end
  end

end
