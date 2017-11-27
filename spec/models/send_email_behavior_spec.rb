require 'rails_helper'

describe Behavior do
  let(:args) { { event_name: :fake_event } }
  let(:journal) { create(:journal) }
  let(:paper) { create(:paper, journal: journal) }
  let(:task) { create(:task, paper: paper, title: 'My Task') }
  let!(:template) { create(:letter_template, journal: journal, ident: 'foo-bar', scenario: 'Manuscript') }
  let(:event) { Event.new(name: :fake_event, paper: paper, task: task, user: paper.creator) }
  subject { build(:send_email_behavior, letter_template: 'foo-bar') }

  before(:each) do
    Event.register(:fake_event)
    allow(Behavior).to receive(:where).with(event_name: :fake_event).and_return([subject])
  end

  after(:each) do
    Event.deregister(:fake_name)
  end

  it_behaves_like :behavior_subclass

  it 'should fail validation unless a letter_template is set' do
    expect(subject).not_to be_valid
  end

  it 'should call the behavior' do
    expect(subject).to receive(:call).with(event)
    event.trigger
  end

  it 'should call GenericMailer to send the email' do
    expect(GenericMailer).to receive_message_chain(:delay, :send_email).with(
      subject: template.subject,
      body: template.body,
      to: template.to,
      task: nil
    )
    event.trigger
  end
end
