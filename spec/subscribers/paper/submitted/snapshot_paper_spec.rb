require 'rails_helper'

describe Paper::Submitted::SnapshotPaper do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let!(:paper) { instance_double(Paper, id: 99, admins: []) }
  let!(:user) { FactoryGirl.build_stubbed(:user) }

  it 'snapshots the paper' do
    expect(SnapshotService).to receive(:snapshot_paper!).with(paper)
    described_class.call("tahi:paper:submitted", record: paper)
  end
end
