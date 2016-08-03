require 'rails_helper'
require 'support/shared_examples/paper_state_transition_shared_examples'

describe Paper do
  let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }
  let(:paper) do
    Timecop.freeze(frozen_time) do
      FactoryGirl.create :paper, :with_creator, journal: journal
    end
  end
  let(:user) { FactoryGirl.create :user }
  let(:frozen_time) { 1.day.ago }

  shared_examples_for "submission" do
    it 'should be unsubmitted' do
      expect(paper.publishing_state).to eq("unsubmitted")
    end

    it 'marks the paper not editable' do
      subject
      expect(paper).to_not be_editable
    end

    it 'sets the updated_at of the latest version' do
      Timecop.freeze(Time.current.utc) do |now|
        expect { subject }
          .to change { paper.latest_version.reload.updated_at }
          .from(within(db_precision_limit).of frozen_time)
          .to(within(db_precision_limit).of now)
      end
    end

    it 'sets the submitted_at' do
      Timecop.freeze do |now|
        expect { subject }
          .to change { paper.submitted_at }
          .from(nil)
          .to(within(db_precision_limit).of now)
      end
    end

    it 'sets the first_submitted_at' do
      Timecop.freeze do |now|
        expect { subject }
          .to change { paper.first_submitted_at }
          .from(nil)
          .to(within(db_precision_limit).of now)
      end
    end

    it "sets the submitting_user of the latest version" do
      draft = paper.draft
      expect { subject }.to change { draft.reload.submitting_user }.from(nil).to(user)
    end

    it "touches the latest version" do
      draft = paper.draft
      Timecop.freeze(1.day.from_now) do |time|
        expect { subject }
          .to change { draft.reload.updated_at }
          .to(within(db_precision_limit).of time)
      end
    end

    it 'snapshots metadata' do
      Subscriptions.reload
      expect(Paper::Submitted::SnapshotPaper).to receive(:call)
      subject
    end

    it 'sets the version numbers of the draft to 0.0' do
      expect { subject }
        .to change { paper.major_version }.from(nil).to(0)
        .and change { paper.minor_version }.from(nil).to(0)
    end
  end

  describe 'constants' do
    describe 'STATES' do
      it 'includes all possible states' do
        expect(Paper::STATES).to contain_exactly(
          :unsubmitted,
          :initially_submitted,
          :invited_for_full_submission,
          :submitted,
          :checking,
          :in_revision,
          :accepted,
          :rejected,
          :published,
          :withdrawn
        )
      end
    end

    describe 'EDITABLE_STATES' do
      it 'defines the paper states for when a paper is editable' do
        expect(Paper::EDITABLE_STATES).to contain_exactly(
          :unsubmitted,
          :in_revision,
          :invited_for_full_submission,
          :checking
        )
      end
    end

    describe 'UNEDITABLE_STATES' do
      it 'defines the paper states for when a paper is not editable' do
        uneditable_states = Paper::STATES - Paper::EDITABLE_STATES
        expect(Paper::UNEDITABLE_STATES).to contain_exactly(*uneditable_states)
      end
    end

    describe 'SUBMITTED_STATES' do
      it 'defines the paper states for when a paper is considered submitted' do
        expect(Paper::SUBMITTED_STATES).to contain_exactly(
          :submitted,
          :initially_submitted
        )
      end
    end

    describe 'REVIEWABLE_STATES' do
      it 'defines the paper states for when a paper is reviewable' do
        reviewable_states = Paper::EDITABLE_STATES + Paper::SUBMITTED_STATES
        expect(Paper::REVIEWABLE_STATES).to contain_exactly(
          *reviewable_states
        )
      end
    end

    describe 'TERMINAL_STATES' do
      it 'defines the paper states for when a paper has exited the workflow' do
        expect(Paper::TERMINAL_STATES).to contain_exactly(
          :accepted,
          :rejected
        )
      end
    end
  end

  describe 'validations' do
    let(:paper) { FactoryGirl.build :paper }

    it 'is valid' do
      expect(paper.valid?).to be(true)
    end

    it 'is not valid without a title' do
      paper.title = nil
      expect(paper.valid?).to be(false)
    end
  end

  context "#create" do
    describe "after_create doi callback" do
      it "the doi is not set coming from factory girl before create" do
        unsaved_paper_from_factory_girl = FactoryGirl.build :paper
        expect(unsaved_paper_from_factory_girl.doi).to eq(nil)
      end

      it "sets a doi in after_create callback" do
        journal                 = FactoryGirl.create :journal
        last_doi_initial        = journal.last_doi_issued
        paper                   = FactoryGirl.create :paper, journal: journal

        expect(paper.doi).to be_truthy
        expect(last_doi_initial.succ).to eq(journal.last_doi_issued) #is incremented in journal
        expect(journal.last_doi_issued).to eq(paper.doi.split('.').last)
      end
    end
  end

  describe '#body' do
    subject(:paper) { Paper.new }
    it 'returns nil by default' do
      expect(paper.body).to be(nil)
    end
  end

  describe "#body=" do
    it "can set body on creation" do
      paper_new = FactoryGirl.create :paper, body: 'foo'
      expect(paper_new.body).to eq('foo')
      expect(paper_new.latest_version.text).to eq('foo')
    end

    it "can use body= before save" do
      paper_new = FactoryGirl.build :paper
      paper_new.body = 'foo'
      expect(paper_new.body).to eq('foo')
      paper.save!
      paper.reload
      expect(paper_new.body).to eq('foo')
    end

    context "when a pending change already exists on paper" do
      let(:paper) { FactoryGirl.create(:paper, journal: journal) }
      before { paper.title = "something new" }

      it "will call event stream once" do
        expect(paper).to receive(:notify).once
        paper.body = "a new body"
        paper.save!
      end
    end

    context "when there are no pending changes on the paper" do
      let(:paper) { FactoryGirl.create(:paper, journal: journal) }

      it "will call event stream once" do
        expect(paper).to receive(:notify).once
        paper.body = "a new body"
        paper.save!
      end
    end
  end

  describe "#destroy" do
    subject { paper.destroy }

    it "is successful" do
      expect(subject).to eq paper
      expect(subject.destroyed?).to eq true
    end

    context "with tasks" do
      let(:paper) { FactoryGirl.create(:paper, :with_tasks, journal: journal) }

      it "delete Phases and Tasks" do
        expect(paper).to have_at_least(1).phase
        expect(paper).to have_at_least(1).task
        paper.destroy

        expect(Phase.where(paper_id: paper.id).count).to be 0
        expect(Task.count).to be 0
      end
    end
  end

  describe "validations" do
    describe "paper_type" do
      it "is required" do
        paper = Paper.new title: 'Example'
        expect(paper).to_not be_valid
        expect(paper).to have(1).errors_on(:paper_type)
      end
    end

    describe "metadata_tasks_completed?" do
      context "paper with completed metadata task" do
        let(:paper) do
          FactoryGirl.create(
            :paper_with_task,
            journal: journal,
            task_params: { type: "MetadataTestTask", completed: true }
          )
        end

        it "returns true" do
          expect(paper.metadata_tasks_completed?).to eq(true)
        end
      end

      context "paper with incomplete metadata task" do
        let(:paper) do
          FactoryGirl.create(
            :paper_with_task,
            journal: journal,
            task_params: { type: "MetadataTestTask", completed: false }
          )
        end

        it "returns false" do
          expect(paper.metadata_tasks_completed?).to eq(false)
        end
      end
    end

    describe '#short_title' do
      let(:title) { "Hi! I'm a title!" }
      let(:paper) do
        FactoryGirl.create(:paper,
          :with_short_title,
          journal: journal,
          short_title: title
        )
      end

      it 'fetches short title from a NestedQuestionAnswer' do
        expect(paper.short_title).to eq(title)
      end
    end

    describe "journal" do
      it "must be present" do
        paper = Paper.new(title: 'YOLO')
        expect(paper).to_not be_valid
      end
    end
  end

  context 'collaboration' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      journal.collaborator_role || journal.create_collaborator_role!
    end

    describe '#add_collaboration' do
      it 'adds the user as a collaborator, returning an assignment' do
        expect do
          collaboration = paper.add_collaboration(user)
          expect(collaboration).to eq(Assignment.last)
        end.to change(paper.collaborators, :count).by(1)
      end

      context 'and the collaborator is already assigned on the paper' do
        it 'does nothing' do
          paper.add_collaboration(user)
          expect do
            paper.add_collaboration(user)
          end.to_not change { paper.collaborators.reload }
        end
      end
    end

    describe '#remove_collaboration' do
      let!(:collaboration) { paper.add_collaboration(user) }

      it 'removes the collaboration given its id' do
        expect do
          paper.remove_collaboration(collaboration.id)
        end.to change(paper.collaborators, :count).by(-1)
        expect { collaboration.reload }.to \
          raise_error(ActiveRecord::RecordNotFound)
      end

      it 'removes the collaboration given a collaborator' do
        expect do
          paper.remove_collaboration(collaboration.user)
        end.to change(paper.collaborators, :count).by(-1)
        expect { collaboration.reload }.to \
          raise_error(ActiveRecord::RecordNotFound)
      end

      it 'removes the collaboration given the collaboration' do
        expect do
          paper.remove_collaboration(collaboration)
        end.to change(paper.collaborators, :count).by(-1)
        expect { collaboration.reload }.to \
          raise_error(ActiveRecord::RecordNotFound)
      end

      it 'does not remove the creator' do
        expect do
          paper.remove_collaboration(paper.creator)
        end.to_not change(paper.collaborators, :count)

        collaboration = paper.collaborations.find_by(user: paper.creator)
        expect do
          paper.remove_collaboration(collaboration)
        end.to_not change(paper.collaborators, :count)

        expect do
          paper.remove_collaboration(collaboration.id)
        end.to_not change(paper.collaborators, :count)

        expect { collaboration.reload }.to_not raise_error
      end
    end
  end

  context 'participation' do
    let(:journal) do
      FactoryGirl.create(
        :journal,
        :with_creator_role,
        :with_collaborator_role,
        :with_handling_editor_role,
        :with_reviewer_role,
        :with_task_participant_role,
        :with_handling_editor_role,
        :with_academic_editor_role
      )
    end
    let(:paper) { FactoryGirl.create(:paper, :with_creator, journal: journal) }
    let(:creator_role) { journal.creator_role }
    let(:collaborator_role) { journal.collaborator_role }
    let(:handling_editor_role) { journal.handling_editor_role }
    let(:reviewer_role) { journal.reviewer_role }
    let(:academic_editor_role) { journal.academic_editor_role }

    let(:creator) { user }
    let(:collaborator) { FactoryGirl.create(:user) }
    let(:handling_editor) { FactoryGirl.create(:user) }
    let(:reviewer) { FactoryGirl.create(:user) }
    let(:academic_editor) { FactoryGirl.create(:user) }

    let!(:creator_assignment) do
      paper.update(creator: user)
      paper.assignments.where(role: creator_role).first!
    end
    let!(:collaborator_assignment) do
      paper.assignments.create!(user: collaborator, role: collaborator_role)
    end
    let!(:handling_editor_assignment) do
      paper.assignments.create!(
        user: handling_editor,
        role: handling_editor_role
      )
    end
    let!(:reviewer_assignment) do
      paper.assignments.create!(user: reviewer, role: reviewer_role)
    end
    let!(:academic_editor_assignment) do
      paper.assignments.create!(user: academic_editor, role: academic_editor_role)
    end

    describe '#participations' do
      it 'returns the assignments for the participants on this paper' do
        expect(paper.participations).to be
      end

      it 'includes the user assigned as the creator of the paper' do
        expect(paper.participations).to include(creator_assignment)
      end

      it 'includes users assigned as collaborators on the paper' do
        expect(paper.participations).to include(collaborator_assignment)
      end

      it 'does not include users assigned as handling editors on the paper' do
        expect(paper.participations).to_not include(handling_editor_assignment)
      end

      it 'includes users assigned as the reviewer on the paper' do
        expect(paper.participations).to include(reviewer_assignment)
      end

      it 'includes users assigned as the academic editor on the paper' do
        expect(paper.participations).to include(academic_editor_assignment)
      end
    end

    describe '#participants' do
      it 'returns the users for all of the participations' do
        expect(paper.participants).to contain_exactly(
          creator, collaborator, reviewer, academic_editor
        )
      end

      context 'and has a user assigned multiple times to the paper' do
        let!(:other_reviewer_assignment) do
          paper.assignments.create!(user: collaborator, role: reviewer_role)
        end

        it 'returns the users only once' do
          expect(paper.participants).to contain_exactly(
            creator, collaborator, reviewer, academic_editor
          )
        end
      end
    end

    describe '#participants_by_role' do
      it 'returns a hash of <role> => [user1, user2, ...]' do
        expect(paper.participants_by_role['Creator']).to eq([creator])
        expect(paper.participants_by_role['Collaborator']).to eq([collaborator])
        expect(paper.participants_by_role['Reviewer']).to eq([reviewer])
        expect(paper.participants_by_role['Academic Editor']).to eq([academic_editor])
      end

      it 'does not include Handling Editor' do
        expect(paper.participants_by_role.keys).to_not include('Handling Editor')
      end

      context 'when a user is assigned different roles on different tasks' do
        let!(:other_reviewer_assignment) do
          paper.assignments.create!(user: collaborator, role: reviewer_role)
        end

        it 'returns the user only once per role' do
          expect(paper.participants_by_role['Collaborator']).to eq([collaborator])
          expect(paper.participants_by_role['Reviewer']).to contain_exactly(reviewer, collaborator)
        end
      end
    end
  end

  context 'State Machine' do
    describe '#initial_submit' do
      subject { paper.initial_submit! user }

      include_examples "transitions save state_updated_at",
        initial_submit: proc { paper.initial_submit! user }
      include_examples 'creates a new draft decision'
      include_examples 'submission'

      it 'transitions to initially_submitted' do
        subject
        expect(paper).to be_initially_submitted
      end
    end

    describe '#submit!' do
      subject { paper.submit! user }
      include_examples "transitions save state_updated_at",
        submit: proc { paper.submit!(paper.creator) }
      include_examples 'creates a new draft decision'
      include_examples 'submission'

      it 'sets the first_submitted_at only once' do
        original_now = Time.current
        paper.update(publishing_state: 'in_revision',
                     first_submitted_at: original_now)
        Timecop.travel(1.day.from_now) do
          subject
          expect(paper.first_submitted_at).to eq(original_now)
        end
      end

      it 'does not transition when metadata tasks are incomplete' do
        expect(paper).to receive(:metadata_tasks_completed?).and_return(false)
        expect { subject }.to raise_error(AASM::InvalidTransition)
      end

      it "transitions to submitted" do
        expect(paper).to receive(:metadata_tasks_completed?).and_return(true)
        subject
        expect(paper).to be_submitted
      end

      it 'sets submitted at to the latest time and sets first_submitted_at initially' do
        Timecop.freeze(frozen_time) do
          expect { paper.initial_submit! user }
            .to change { paper.submitted_at }
            .from(nil)
            .to(within(db_precision_limit).of(frozen_time))
            .and change { paper.first_submitted_at }
            .from(nil)
            .to(within(db_precision_limit).of(frozen_time))
        end

        paper.invite_full_submission!
        Timecop.freeze do |now|
          expect { paper.submit! user }
            .to change { paper.submitted_at }
            .from(within(db_precision_limit).of(frozen_time))
            .to(within(db_precision_limit).of(now))
        end
      end

      it "broadcasts 'paper:submitted' event" do
        allow(Notifier).to receive(:notify)
        expect(Notifier).to receive(:notify).with(hash_including(event: "paper:submitted")) do |args|
          expect(args[:data][:record]).to eq(paper)
        end
        paper.submit! user
      end

      context 'called on a paper invited for full submission' do
        before do
          paper.initial_submit! user
          paper.invite_full_submission!
        end

        it 'increments the minor version' do
          expect { subject }.to change { paper.minor_version }.from(0).to(1)
        end

        it 'keeps the major version' do
          expect { subject }.not_to change { paper.major_version }
        end
      end

      context 'called on a paper in revision' do
        before do
          paper.submit! user
          paper.major_revision!
        end

        it 'increments the major version' do
          expect { paper.submit!(user) }.to change { paper.major_version }.by(1)
        end

        it 'does not change the minor version' do
          expect { paper.submit!(user) }.to_not change { paper.minor_version }
        end
      end
    end

    describe '#latest_withdrawal' do
      let!(:joe) { FactoryGirl.create(:user) }
      let!(:sally) { FactoryGirl.create(:user) }

      before do
        paper.withdraw!('reason 1', joe)
        paper.reload.reactivate!
        paper.withdraw!('reason 2', sally)
      end

      it 'returns the most recent withdrawal' do
        withdrawal = paper.latest_withdrawal
        expect(withdrawal).to be_kind_of(Withdrawal)
        expect(withdrawal.withdrawn_by_user).to eq(sally)
        expect(withdrawal.reason).to eq('reason 2')
      end
    end

    describe '#withdraw!' do
      let(:withdrawn_by_user) { FactoryGirl.build_stubbed(:user) }

      include_examples "transitions save state_updated_at",
        withdraw: proc { paper.withdraw! 'A withdrawal reason', withdrawn_by_user }

      let(:paper) do
        FactoryGirl.create(:paper, :submitted, journal: journal)
      end

      it "raises an error when withdrawing without a reason and withdrawn_by_user" do
        expect do
          paper.withdraw!
        end.to raise_error(ArgumentError, 'withdrawal_reason must be provided')

        expect do
          paper.withdraw! 'reason, but no user'
        end.to raise_error(ArgumentError, 'withdrawn_by_user must be provided')
      end

      it 'withdraws the paper' do
        paper.withdraw! 'reason', withdrawn_by_user
        expect(paper).to be_withdrawn
      end

      it "transitions to withdrawn with a reason" do
        paper.withdraw! "Don't want to.", withdrawn_by_user
        expect(paper.withdrawn?).to eq true
      end

      it "marks the paper not editable" do
        paper.withdraw! "Some reason", withdrawn_by_user
        expect(paper).to_not be_editable
      end
    end

    describe '#invite_full_submission' do
      include_examples "transitions save state_updated_at",
        invite_full_submission: proc { paper.invite_full_submission! }

      let(:paper) do
        FactoryGirl.create(:paper, :initially_submitted, journal: journal)
      end

      it 'transitions to invited_for_full_submission' do
        paper.invite_full_submission!
        expect(paper.publishing_state).to eq('invited_for_full_submission')
      end

      it 'marks the paper editable' do
        paper.invite_full_submission!
        expect(paper).to be_editable
      end
    end

    describe '#reactivate!' do
      include_examples "transitions save state_updated_at",
        reactivate: proc { paper.reactivate! }

      let(:paper) do
        FactoryGirl.create(:paper, :submitted, journal: journal)
      end

      let(:unsubmitted_paper) do
        FactoryGirl.create(:paper, :unsubmitted, journal: journal)
      end

      before do
        paper.withdraw!('some reason', FactoryGirl.build_stubbed(:user))
      end

      it "transitions to the previous state" do
        expect(paper).to be_withdrawn
        paper.reload.reactivate!
        expect(paper).to be_submitted
      end

      it "marks the paper with the previous editable state for submitted papers" do
        expect(paper).to_not be_editable
        paper.reload.reactivate!
        expect(paper).to_not be_editable
        expect(paper.submitted?).to eq(true)
      end

      it "marks the paper with the previous editable state for unsubmitted papers" do
        paper = unsubmitted_paper
        expect(paper).to be_editable
        paper.withdraw!('some reason', FactoryGirl.build_stubbed(:user))
        expect(paper).to_not be_editable
        paper.reload.reactivate!
        expect(paper).to be_editable
        expect(paper.unsubmitted?).to eq(true)
      end
    end

    describe '#minor_check!' do
      include_examples "transitions save state_updated_at",
        minor_check: proc { paper.minor_check! }

      let(:paper) do
        FactoryGirl.create(:paper, :submitted, journal: journal)
      end

      it "marks the paper editable" do
        paper.minor_check!
        expect(paper).to be_editable
      end
    end

    describe '#submit_minor_check!' do
      subject { paper.submit_minor_check! user }

      include_examples "transitions save state_updated_at",
        submit_minor_check: proc { paper.submit_minor_check!(paper.creator) }

      let(:paper) do
        FactoryGirl.create(:paper, :submitted, journal: journal)
      end

      before do
        paper.minor_check!
      end

      it "keeps the draft decision from before" do
        expect { subject }.to_not change { paper.draft_decision }
      end

      it "marks the paper uneditable" do
        expect { paper.submit_minor_check! user }
          .to change { paper.editable }.to(false)
      end

      it "sets the submitting_user of the latest version" do
        paper.submit_minor_check! user
        expect(paper.latest_submitted_version.submitting_user).to eq(user)
      end

      it "sets the updated_at of the latest version" do
        paper.latest_version.update!(updated_at: 10.days.ago)
        Timecop.freeze do |now|
          paper.submit_minor_check! user
          expect(paper.latest_submitted_version.updated_at.utc)
            .to be_within(db_precision_limit).of(now)
        end
      end

      it 'increments the minor version' do
        expect { paper.submit_minor_check!(user) }.to change { paper.minor_version }.by(1)
      end
    end

    describe '#accept' do
      context 'paper is submitted' do
        let(:paper) do
          FactoryGirl.create(:paper, :submitted, journal: journal)
        end

        include_examples "transitions save state_updated_at",
          accept: proc { paper.accept! }

        it 'transitions to accepted state from submitted' do
          paper.accept!
          expect(paper.accepted?).to be true
        end
      end
    end

    describe '#reject' do
      context 'paper is submitted' do
        let(:paper) do
          FactoryGirl.create(:paper, :submitted, journal: journal)
        end

        include_examples "transitions save state_updated_at",
          reject: proc { paper.reject! }

        it 'transitions to rejected state from submitted' do
          paper.reject!
          expect(paper.rejected?).to be true
        end
      end

      context 'paper is initially_submitted' do
        let(:paper) do
          FactoryGirl.create(
            :paper,
            :initially_submitted,
            journal: journal
          )
        end

        include_examples "transitions save state_updated_at",
          reject: proc { paper.reject! }

        it 'transitions to rejected state from initially_submitted' do
          paper.reject!
          expect(paper.rejected?).to be true
        end
      end
    end

    describe '#publish!' do
      include_examples "transitions save state_updated_at",
        publish: proc { paper.publish! }

      let(:paper) do
        FactoryGirl.create(:paper, :submitted, journal: journal)
      end

      it "marks the paper uneditable" do
        paper.publish!
        expect(paper.published_at).to be_truthy
      end
    end

    describe '#rescind!' do
      context 'when rejected after full submission' do
        let(:paper) do
          paper = FactoryGirl.create(:paper, :submitted, journal: journal)
          paper.draft_decision.update(verdict: 'reject', letter: 'it stinks')
          paper.draft_decision.register! FactoryGirl.create(:register_decision_task)
          paper
        end

        include_examples "transitions save state_updated_at", rescind: proc { paper.rescind! }

        it "transitions to submitted from rejected" do
          paper.rescind!
          expect(paper.publishing_state).to eq("submitted")
        end

        it "creates a new decision for terminal states" do
          expect { paper.rescind! }.to change { paper.decisions.count }.by(1)
        end
      end

      context 'when rejected after initial submission' do
        let(:paper) do
          paper = FactoryGirl.create(:paper, publishing_state: :initially_submitted, journal: journal)
          paper.reject!
          paper
        end

        include_examples "transitions save state_updated_at", rescind: proc { paper.rescind! }

        it "transitions to initially_submitted from rejected" do
          paper.rescind!
          expect(paper.publishing_state).to eq("initially_submitted")
        end
      end

      context 'after a request for revision' do
        let(:paper) do
          paper = FactoryGirl.create(:paper, :submitted, journal: journal)
          paper.major_revision!
          paper
        end

        it "transitions to submitted" do
          paper.rescind!
          expect(paper.publishing_state).to eq("submitted")
        end

        it "does not creates a new decision" do
          expect { paper.rescind! }.to_not change { paper.decisions.count }
        end
      end
    end
  end

  describe "transitions from submitted" do
    let(:paper) do
      FactoryGirl.create(:paper, :submitted, journal: journal)
    end

    describe "#accept!" do
      it "accepts the paper" do
        paper.accept!
        expect(paper.publishing_state).to eq("accepted")
      end

      it "sets accepted_at" do
        Timecop.freeze do |now|
          paper.accept!
          expect(paper.accepted_at.utc).to be_within(db_precision_limit).of now
        end
      end
    end

    describe "#major_revision!" do
      it "puts the paper in_revision" do
        paper.major_revision!
        expect(paper.publishing_state).to eq("in_revision")
      end
    end

    describe "#minor_revision!" do
      it "puts the paper in_revision" do
        paper.minor_revision!
        expect(paper.publishing_state).to eq("in_revision")
      end
    end
  end

  describe "#major_version" do
    context "when there are versions" do
      before do
        paper.submit! user
      end

      it "returns the latest version's major_version" do
        expect(paper.major_version).to eq(paper.latest_submitted_version.major_version)
      end
    end

    context "when there is no latest_version" do
      before do
        paper.versioned_texts.destroy_all
        expect(paper.latest_version).to be(nil)
      end

      it "returns nil" do
        expect(paper.major_version).to be(nil)
      end
    end
  end

  describe "#minor_version" do
    context "when there are versions" do
      before do
        paper.submit! user
      end

      it "returns the latest version's minor_version" do
        expect(paper.major_version).to eq(paper.latest_submitted_version.minor_version)
      end
    end

    context "when there is no latest_version" do
      before do
        paper.versioned_texts.destroy_all
        expect(paper.latest_version).to be(nil)
      end

      it "returns nil" do
        expect(paper.major_version).to be(nil)
      end
    end
  end

  describe "callbacks" do
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:creator) { paper.creator }

    it "assigns all author tasks to the paper's creator" do
      paper.save!
      author_tasks = Task.where(old_role: 'author', phase_id: paper.phases.pluck(:id))
      other_tasks = Task.where("old_role != 'author'", phase_id: paper.phases.pluck(:id))
      expect(author_tasks.all? { |t| t.assignee == creator }).to eq true
      expect(other_tasks.all? { |t| t.assignee != creator }).to eq true
    end
  end

  describe '#collaborators' do
    let(:creator) { paper.creator }
    let(:collaborator) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    let(:creator_role) do
      Role.ensure_exists(Role::CREATOR_ROLE, journal: paper.journal)
    end
    let(:collaborator_role) do
      Role.ensure_exists(Role::COLLABORATOR_ROLE, journal: paper.journal)
    end
    let(:other_role) do
      FactoryGirl.create(:role, name: 'Other Role', journal: paper.journal)
    end

    before do
      paper.assignments.create!(role: collaborator_role, user: collaborator)
      paper.assignments.create!(role: other_role, user: other_user)
    end

    it 'returns only users assigned with the Creator and Collaborator role' do
      expect(paper.collaborators).to contain_exactly(creator, collaborator)
    end

    it 'does not return users assigned with other roles' do
      expect(paper.collaborators).to_not include(other_user)
    end
  end

  describe '#corresponding_author_emails' do
    it 'returns an array of correspondence emails' do
      expect(paper.corresponding_author_emails).to be_kind_of(Array)
    end

    context 'and there is not a creator or any authors' do
      subject(:paper) { FactoryGirl.create(:paper) }

      before do
        # ensure we're starting with a blank slate
        expect(paper.creator).to be nil
        expect(paper.authors).to be_empty
      end

      it 'returns an empty array' do
        expect(paper.corresponding_author_emails).to eq []
      end
    end

    context 'and there is a creator' do
      subject(:paper) do
        FactoryGirl.create(:paper, :with_creator, journal: journal)
      end
      let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }

      before { expect(paper.creator).to be }

      context 'and there are no authors' do
        before { expect(paper.reload.authors).to be_empty }

        it "includes the creator's email" do
          expect(paper.corresponding_author_emails).to \
            contain_exactly(paper.creator.email)
        end
      end

      context 'and there are authors' do
        let(:author_1) do
          FactoryGirl.create(:author, email: 'a1@example.com')
        end
        let(:author_2) do
          FactoryGirl.create(:author, email: 'a2@example.com')
        end
        let(:corresponding_author_1) do
          FactoryGirl.create(:author, :corresponding, email: 'c1@example.com')
        end
        let(:corresponding_author_2) do
          FactoryGirl.create(:author, :corresponding, email: 'c2@example.com')
        end

        before do
          paper.authors = [author_1, author_2]
          expect(paper.authors).to_not be_empty
        end

        it "includes the creator's email when no author is corresponding" do
          expect(paper.corresponding_author_emails).to \
            contain_exactly(paper.creator.email)
        end

        it "includes all corresponding author emails otherwise" do
          paper.authors << corresponding_author_1
          paper.authors << corresponding_author_2
          expect(paper.corresponding_author_emails).to contain_exactly(
            corresponding_author_1.email,
            corresponding_author_2.email
          )
        end
      end
    end
  end

  describe 'academic editors' do
    before do
      journal.academic_editor_role ||
        journal.create_academic_editor_role!
    end

    it 'has none by default' do
      expect(paper.academic_editors).to eq([])
    end

    describe '#add_academic_editor' do
      let(:editor_1) { FactoryGirl.create(:user) }
      let(:editor_2) { FactoryGirl.create(:user) }

      it 'adds the given academic editor to the paper' do
        expect do
          paper.add_academic_editor(editor_1)
        end.to change { paper.academic_editors.count }.by 1
        expect(paper.academic_editors).to contain_exactly(editor_1)

        expect do
          paper.add_academic_editor(editor_2)
        end.to change { paper.academic_editors.count }.by 1
        expect(paper.academic_editors).to contain_exactly(editor_1, editor_2)
      end

      it 'returns the academic editor assignment' do
        expect(paper.add_academic_editor(editor_1)).to eq \
          Assignment.find_by(
            assigned_to: paper,
            role: paper.journal.academic_editor_role,
            user: editor_1
          )
      end

      context 'and the academic editor is already assigned on the paper' do
        it 'does nothing' do
          paper.add_academic_editor(editor_1)
          expect do
            paper.add_academic_editor(editor_1)
          end.to_not change { paper.academic_editors.reload }
        end
      end
    end
  end

  describe '#roles_for' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:role_1_assigned) { FactoryGirl.create(:role) }
    let!(:role_2_assigned) { FactoryGirl.create(:role) }
    let!(:role_3_not_assigned) { FactoryGirl.create(:role) }
    let(:paper_with_roles) do
      Paper.where(id: paper.id).includes(:roles).first
    end

    before do
      paper.assignments.create!(user: user, role: role_1_assigned)
      paper.assignments.create!(user: user, role: role_2_assigned)
    end

    it "returns the user's roles on the paper" do
      expect(
        paper.roles_for(user: user)
      ).to contain_exactly(role_1_assigned, role_2_assigned)
    end

    it "returns the user's roles on the paper when roles are eager loaded" do
      expect(paper_with_roles.roles.loaded?).to be(true)
      expect(paper_with_roles.roles_for(user: user)).to \
        contain_exactly(role_1_assigned, role_2_assigned)
    end

    context "when the user isn't assigned to any roles" do
      before { paper.assignments.destroy_all }

      it 'returns nothing' do
        expect(paper.roles_for(user: user)).to be_empty
      end
    end

    context 'when called with the optional :roles parameter' do
      it "returns the user's roles on the paper scoped to the given roles" do
        expect(
          paper.roles_for(user: user, roles: [role_2_assigned])
        ).to contain_exactly(role_2_assigned)
      end

      it "returns nothing when the user isn't assigned to the given roles" do
        expect(
          paper.roles_for(user: user, roles: [role_3_not_assigned])
        ).to be_empty
      end
    end
  end

  describe '#role_descriptions_for' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:role) { FactoryGirl.create(:role, name: 'ABC') }

    it 'returns the names of the roles the user is assigned to' do
      paper.assignments.create!(user: user, role: role)
      expect(paper.role_descriptions_for(user: user)).to contain_exactly('ABC')
    end

    it 'returns "My Paper" when the role is the journal creator' do
      paper.assignments.create!(user: user, role: paper.journal.creator_role)
      expect(
        paper.role_descriptions_for(user: user)
      ).to contain_exactly('My Paper')
    end
  end

  describe '#snapshottable_things' do
    subject(:paper) { Paper.new }
    let(:task) do
      FactoryGirl.build_stubbed(:task, paper: paper, snapshottable: true)
    end
    let(:figure) { FactoryGirl.build_stubbed(:figure, paper: paper) }
    let(:si_file) do
      FactoryGirl.build_stubbed(:supporting_information_file, paper: paper)
    end
    let(:adhoc_attachment) do
      FactoryGirl.build_stubbed(:adhoc_attachment, paper: paper)
    end
    let(:question_attachment) do
      FactoryGirl.build_stubbed(:question_attachment, paper: paper)
    end

    it 'returns the independently snapshottable things about a paper' do
      expect(paper.snapshottable_things).to be_kind_of(Array)
    end

    it 'includes snapshottable tasks' do
      paper.tasks.push task
      expect(paper.snapshottable_things).to include(task)

      task.snapshottable = false
      expect(paper.snapshottable_things).to_not include(task)
    end

    it 'includes snapshottable figures' do
      paper.figures.push figure
      expect(paper.snapshottable_things).to include(figure)

      figure.snapshottable = false
      expect(paper.snapshottable_things).to_not include(figure)
    end

    it 'includes snapshottable supporting_information_files' do
      paper.supporting_information_files.push si_file
      expect(paper.snapshottable_things).to include(si_file)

      si_file.snapshottable = false
      expect(paper.snapshottable_things).to_not include(si_file)
    end

    it 'includes snapshottable adhoc_attachments' do
      paper.adhoc_attachments.push adhoc_attachment
      expect(paper.snapshottable_things).to include(adhoc_attachment)

      adhoc_attachment.snapshottable = false
      expect(paper.snapshottable_things).to_not include(adhoc_attachment)
    end

    it 'includes snapshottable question_attachments' do
      paper.question_attachments.push question_attachment
      expect(paper.snapshottable_things).to include(question_attachment)

      question_attachment.snapshottable = false
      expect(paper.snapshottable_things).to_not include(question_attachment)
    end
  end

  describe "#abstract" do
    before do
      paper.update(body: "a bunch of words")
    end

    context "with an #abstract field value" do
      before do
        paper.update(abstract: "an abstract about a bunch of words")
      end

      it "returns #abstract" do
        expect(paper.abstract).to eq "an abstract about a bunch of words"
      end
    end

    context "without an #abstract field value" do
      it "returns an empty abstract" do
        expect(paper.abstract).to be_empty
      end
    end
  end

  describe "#latest_submitted_version" do
    before do
      # create a bunch of old minor versions
      FactoryGirl.create(:versioned_text, paper: paper, major_version: 0, minor_version: 1)
      FactoryGirl.create(:versioned_text, paper: paper, major_version: 0, minor_version: 2)
    end
    let!(:latest) do
      FactoryGirl.create(:versioned_text, paper: paper, major_version: 0, minor_version: 3)
    end

    it "returns the latest version" do
      versioned_text = FactoryGirl.create(:versioned_text, paper: paper, major_version: 1, minor_version: 0)
      expect(paper.latest_submitted_version).to eq(versioned_text)
    end

    it "does not return a draft even if there is one" do
      expect(paper.draft).to be_present
      expect(paper.latest_submitted_version).to eq(latest)
    end
  end

  describe "#latest_version" do
    before do
      # create a bunch of old minor versions
      paper.versioned_texts = []
      paper.save!
      FactoryGirl.create(:versioned_text, paper: paper, major_version: 0, minor_version: 1)
      FactoryGirl.create(:versioned_text, paper: paper, major_version: 0, minor_version: 2)
      FactoryGirl.create(:versioned_text, paper: paper, major_version: 0, minor_version: 3)
    end

    it "returns the latest version" do
      versioned_text = FactoryGirl.create(:versioned_text, paper: paper, major_version: 1, minor_version: 0)
      expect(paper.latest_version).to eq(versioned_text)
    end

    it "returns a draft if there is one" do
      versioned_text = FactoryGirl.create(:versioned_text, paper: paper, major_version: nil, minor_version: nil)
      expect(paper.latest_version).to eq(versioned_text)
    end
  end

  describe "#draft" do
    it "returns a VersionedText with no version" do
      draft = paper.draft
      expect(draft.major_version).to be_nil
      expect(draft.minor_version).to be_nil
    end

    context 'when there is no draft' do
      let(:paper) { FactoryGirl.create :paper, :submitted, journal: journal }
      it 'returns nil' do
        expect(paper.draft).to be_nil
      end
    end
  end

  describe "#awaiting_decision?" do
    it "is true when the paper is submitted" do
      paper = FactoryGirl.build(:paper, publishing_state: "submitted")
      expect(paper.awaiting_decision?).to be(true)
    end
    it "is true when the paper is initially submitted" do
      paper = FactoryGirl.build(:paper, publishing_state: "initially_submitted")
      expect(paper.awaiting_decision?).to be(true)
    end
    it "is not true otherwise" do
      paper = FactoryGirl.build(:paper, publishing_state: "rejected")
      expect(paper.awaiting_decision?).to be(false)
    end
  end

  describe "#display_title" do
    context "title is present, short title is nil" do
      let(:paper) { FactoryGirl.build(:paper, title: '<b>my long paper</b>') }

      context "with sanitization" do
        it "it is sanitized title" do
          expect(paper.display_title).to eq("my long paper")
        end
      end

      context "without sanitization" do
        it "is is unsanitized title" do
          expect(paper.display_title(sanitized: false)).to eq("<b>my long paper</b>")
        end
      end
    end

    context "title is present, short title is present" do
      let(:paper) do
        FactoryGirl.create(
          :paper,
          :with_short_title,
          journal: journal,
          short_title: '<b>my paper</b>',
          title: '<b>my long paper</b>')
      end

      context "with sanitization" do
        it "it is sanitized title" do
          expect(paper.display_title).to eq("my long paper")
        end
      end

      context "without sanitization" do
        it "is is unsanitized title" do
          expect(paper.display_title(sanitized: false)).to eq("<b>my long paper</b>")
        end
      end
    end
  end

  describe 'Paper::(UN)EDITABLE_STATES' do
    it 'should contain the right states' do
      expect(Paper::EDITABLE_STATES).to contain_exactly(:unsubmitted, :in_revision, :invited_for_full_submission, :checking)
      expect(Paper::UNEDITABLE_STATES).to contain_exactly(:submitted, :accepted, :initially_submitted, :published, :rejected, :withdrawn)
    end

    it 'editable + uneditable should be ALL the states' do
      expect(Paper::EDITABLE_STATES + Paper::UNEDITABLE_STATES)
        .to contain_exactly(*Paper.aasm.states.map(&:name))
    end
  end

  describe '#new_draft_decision!' do
    it 'creates a new decision' do
      expect { paper.send(:new_draft_decision!) }
        .to change { paper.decisions.count }.from(0).to(1)
    end

    it 'noops if a draft decision exists' do
      paper.send(:new_draft_decision!)
      expect { paper.send(:new_draft_decision!) }
        .not_to change { paper.decisions.count }
    end
  end

  describe '#last_of_task' do
    let!(:revise_task) { create :revise_task, paper: paper }

    it "returns the task instance" do
      task = paper.last_of_task(TahiStandardTasks::ReviseTask)
      expect(task).to eq revise_task
    end

    it "returns nil if their is no task of the correct type" do
      task = paper.last_of_task(TahiStandardTasks::AuthorsTask)
      expect(task).to be_nil
    end
  end
end
