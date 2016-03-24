require 'rails_helper'

describe Paper::Resubmitted::EmailAcademicEditors do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let(:paper) { FactoryGirl.build_stubbed(:paper) }
  let(:editor_1) { FactoryGirl.build_stubbed(:user) }
  let(:editor_2) { FactoryGirl.build_stubbed(:user) }

  before do
    allow(paper).to receive(:academic_editors)
      .and_return [editor_1, editor_2]
  end

  it 'sends an email to academic editors on the paper' do
    expect(mailer).to receive(:notify_academic_editor_of_paper_resubmission)
      .with(paper.id, editor_1.id)
    expect(mailer).to receive(:notify_academic_editor_of_paper_resubmission)
      .with(paper.id, editor_2.id)

    described_class.call('tahi:paper:resubmitted', record: paper)
  end
end
