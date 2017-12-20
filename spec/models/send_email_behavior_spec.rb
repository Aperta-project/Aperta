require 'rails_helper'

describe Behavior do
  let(:args) { { event_name: :fake_event } }
  let(:journal) { create(:journal) }
  let(:paper) { create(:paper, journal: journal) }
  let(:task) { create(:task, paper: paper, title: 'My Task') }
  let!(:template) { create(:letter_template, journal: journal, ident: 'foo-bar', scenario: 'Manuscript') }
  let(:event) { Event.new(name: :fake_event, paper: paper, task: task, user: paper.creator) }
  subject { create(:send_email_behavior, event_name: :fake_event, journal: journal, letter_template: 'foo-bar') }

  before(:each) do
    Event.register(:fake_event)
    subject.save!
  end

  after(:each) do
    Event.deregister(:fake_event)
  end

  it_behaves_like :behavior_subclass

  it 'should fail validation unless a letter_template is set' do
    subject.letter_template = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:letter_template]).to eq(["can't be blank"])
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
