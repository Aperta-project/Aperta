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

describe Task do
  it_behaves_like 'is not snapshottable'

  describe ".without" do
    let!(:tasks) { FactoryGirl.create_list(:custom_card_task, 2, :with_stubbed_associations) }

    it "excludes task" do
      expect(Task.count).to eq(2)
      expect(Task.without(tasks.last).count).to eq(1)
    end
  end

  describe '#add_participant' do
    subject(:task) { FactoryGirl.create :ad_hoc_task, paper: paper }
    let(:paper) { FactoryGirl.create :paper, journal: journal }
    let(:journal) { FactoryGirl.create(:journal, :with_task_participant_role) }
    let(:user) { FactoryGirl.create :user }

    it 'adds the user as a participant on the task' do
      expect(task.participants.count).to eq(0)
      task.add_participant(user)
      expect(task.participants.count).to eq(1)
    end

    it 'does not add them more than once' do
      task.add_participant(user)
      task.add_participant(user)
      task.add_participant(user)
      expect(task.participants.count).to eq(1)
    end
  end

  describe '#assignments' do
    subject(:task) { FactoryGirl.create :ad_hoc_task, :with_stubbed_associations }

    before do
      Assignment.create!(
        user: FactoryGirl.create(:user),
        role: FactoryGirl.create(:role),
        assigned_to: task
      )
    end

    context 'on #destroy' do
      it 'destroy assignments' do
        expect do
          task.destroy!
        end.to change { task.assignments.count }.by(-1)
      end
    end
  end

  describe '#participations' do
    subject(:task) { FactoryGirl.create :ad_hoc_task, paper: paper }
    let(:paper) { FactoryGirl.create :paper, journal: journal }
    let(:journal) { FactoryGirl.create(:journal, :with_task_participant_role) }

    let!(:participant_assignment) do
      Assignment.create!(
        user: FactoryGirl.create(:user),
        role: task.journal.task_participant_role,
        assigned_to: task
      )
    end

    let!(:other_assignment) do
      Assignment.create!(
        user: FactoryGirl.create(:user),
        role: FactoryGirl.create(:role),
        assigned_to: task
      )
    end

    it 'returns the assignments where the role is participant' do
      expect(task.participations).to contain_exactly(participant_assignment)
      expect(task.participations).to_not include(other_assignment)
    end
  end

  describe '#participants' do
    subject(:task) { FactoryGirl.create :ad_hoc_task, paper: paper }
    let(:paper) { FactoryGirl.create :paper, journal: journal }
    let(:journal) { FactoryGirl.create(:journal, :with_task_participant_role) }

    let!(:participant_assignment) do
      Assignment.create!(
        user: FactoryGirl.create(:user),
        role: task.journal.task_participant_role,
        assigned_to: task
      )
    end

    let!(:other_assignment) do
      Assignment.create!(
        user: FactoryGirl.create(:user),
        role: FactoryGirl.create(:role),
        assigned_to: task
      )
    end

    it 'returns the users who are assigned to the task as a participant' do
      expect(task.participants).to contain_exactly(participant_assignment.user)
      expect(task.participants).to_not include(other_assignment.user)
    end
  end

  describe '#answers_validated?' do
    subject(:task) { FactoryGirl.create(:task, :with_card, title: 'AwesomeSauce') }
    let(:answer) { FactoryGirl.create(:answer, owner: subject) }
    let(:card_content) { subject.card.latest_card_version.card_contents.first }
    let(:card_content_validation) do
      FactoryGirl.create(:card_content_validation,
        :with_string_match_validation,
        card_content: card_content,
        validator: 'abby')
    end
  end

  describe "#invitations" do
    let(:paper) { FactoryGirl.create :paper }
    let(:task) { FactoryGirl.create :invitable_task, paper: paper }
    let!(:invitation) { FactoryGirl.create :invitation, task: task }

    context "on #destroy" do
      it "destroy invitations" do
        expect do
          task.destroy!
        end.to change { Invitation.count }.by(-1)
      end
    end
  end

  describe "Answerable#answers" do
    it "destroys answers on destroy" do
      task = FactoryGirl.create(:ad_hoc_task)
      answer = FactoryGirl.create(:answer, owner: task)
      expect(task.answers.pluck(:id)).to contain_exactly(answer.id)

      task.destroy
      expect(Answer.count).to eq(0)
    end
  end

  describe "Answerable#answer_for" do
    subject(:task) { FactoryGirl.create(:ad_hoc_task, :with_stubbed_associations) }
    let!(:answer_foo) do
      FactoryGirl.create(
        :answer,
        owner: task,
        value: "the answer",
        card_content: FactoryGirl.create(:card_content, ident: "foo")
      )
    end

    it "returns the answer for the question matching the given ident" do
      expect(task.answer_for("foo")).to eq(answer_foo)
    end

    it "returns nil if there is no answer for the given ident" do
      expect(task.answer_for("unknown-ident")).to be(nil)
    end
  end

  describe "Answerable#set_card_version" do
    before { CardLoader.load("AdHocTask") }
    let(:latest_card_version) { task.default_card.latest_published_card_version }

    context "with no card version" do
      let(:task) { AdHocTask.new }

      it "assigns the latest card version if not set" do
        expect { task.valid? }.to change { task.card_version }
          .from(nil).to(latest_card_version)
      end
    end

    context "with card version already set" do
      let(:task) { AdHocTask.new(card_version: FactoryGirl.build(:card_version)) }

      it "assigns the latest card version if not set" do
        expect { task.valid? }.to_not change { task.card_version }
      end
    end
  end

  describe 'Task.safe_constantize' do
    it 'fails with Task' do
      expect { Task.safe_constantize('Task') }
        .to raise_error(/disallowed value/)
    end

    it 'works with Task descendants' do
      expect(Task.safe_constantize('TahiStandardTasks::TaxonTask'))
        .to eq(TahiStandardTasks::TaxonTask)
    end

    it 'fails with non-tasks' do
      expect { Task.safe_constantize('User') }
        .to raise_error(/disallowed value/)
    end
  end

  describe "#can_change?: associations can use this method to update based on task" do
    let(:task) do
      FactoryGirl.create(:ad_hoc_task, :with_stubbed_associations)
    end

    it "returns true" do
      expect(task.can_change?(double)).to eq(true)
    end
  end

  describe '#assigned_user' do
    let(:task) { FactoryGirl.create :ad_hoc_task, paper: paper }
    let(:paper) { FactoryGirl.create :paper, journal: journal }
    let(:journal) { FactoryGirl.create(:journal, :with_task_participant_role) }
    let(:assignedUser) { FactoryGirl.create(:user) }

    it 'returns an user when assigned_user_id is present' do
      task.update(assigned_user_id: assignedUser.id)
      expect(task.assigned_user).to be == assignedUser
    end

    it 'returns nil when assigned_user_id is not present' do
      expect(task.assigned_user).to be_nil
    end
  end
end
