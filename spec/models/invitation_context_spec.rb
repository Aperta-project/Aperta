require 'rails_helper'

describe InvitationContext do
  subject(:context) do
    InvitationContext.new(invitation)
  end

  let(:invitation) do
    FactoryGirl.build(:invitation, :invited)
  end

  let(:flag) do
    FactoryGirl.create(:feature_flag, name: 'REVIEW_DUE_DATE')
  end

  context 'rendering an invitation' do
    before do
      journal = invitation.paper.journal
      manuscript_manager_template = FactoryGirl.create(:manuscript_manager_template, paper_type: 'research', journal: journal)
      journal_task_type = FactoryGirl.create(:journal_task_type, journal: journal, kind: 'TahiStandardTasks::PaperReviewerTask')
      phase_template = FactoryGirl.create(:phase_template, manuscript_manager_template: manuscript_manager_template)
      task_template = FactoryGirl.create(:task_template, journal_task_type: journal_task_type, phase_template: phase_template)
      FactoryGirl.create(:setting, owner: task_template, name: 'review_duration_period', integer_value: 9, value_type: 'integer')
    end

    def check_render(template, expected)
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(expected)
    end

    it 'renders the state' do
      check_render("{{ state }}", invitation.state)
    end

    context 'has review due date feature flag' do
      before do
        flag.update(active: true)
      end

      it 'renders the setting value (9) as the review duration period' do
        check_render("{{ due_in_days }}", "9")
      end
    end

    context 'does not have review due date feature flag' do
      before do
        flag.update(active: false)
      end

      it 'renders the default value (10) as the review duration period' do
        check_render("{{ due_in_days }}", "10")
      end
    end
  end
end
