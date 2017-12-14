require 'rails_helper'

describe InvitationContext do
  subject(:context) do
    InvitationContext.new(invitation)
  end

  let(:invitation) do
    FactoryGirl.build(:invitation, :invited)
  end

  def check_render(template, expected)
    expect(LetterTemplate.new(body: template).render(context).body).to eq(expected)
  end

  def make_template(invitation)
    journal = invitation.paper.journal
    manuscript_manager_template = FactoryGirl.create(:manuscript_manager_template, paper_type: 'research', journal: journal)
    journal_task_type = FactoryGirl.create(:journal_task_type, journal: journal, kind: 'TahiStandardTasks::PaperReviewerTask')
    phase_template = FactoryGirl.create(:phase_template, manuscript_manager_template: manuscript_manager_template)
    FactoryGirl.create(:task_template, journal_task_type: journal_task_type, phase_template: phase_template)
  end

  context 'rendering an invitation for the default review duration' do
    before do
      make_template(invitation)
    end

    context 'does not have review due date' do
      it 'renders the default value (10) as the review duration period' do
        check_render("{{ due_in_days }}", "10")
      end
    end
  end

  context 'rendering an invitation for a specific review duration' do
    before do
      task_template = make_template(invitation)
      FactoryGirl.create(:setting, owner: task_template, name: 'review_duration_period', integer_value: 9, value_type: 'integer')
    end

    it 'renders the state' do
      check_render("{{ state }}", invitation.state)
    end

    context 'has review due date' do
      it 'renders the setting value (9) as the review duration period' do
        check_render("{{ due_in_days }}", "9")
      end
    end
  end
end
