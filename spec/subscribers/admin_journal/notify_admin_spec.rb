require 'rails_helper'

describe AdminJournal::NotifyAdmin do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:admin_journal) { FactoryGirl.build(:journal) }

  it "serializes journal down the admin channel" do
    expect(pusher_channel).to receive_push(serialize: admin_journal, down: 'admin', on: 'updated')
    described_class.call("tahi:journal:updated", action: "updated", record: admin_journal)
  end
end
