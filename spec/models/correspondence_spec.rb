require 'rails_helper'

describe Correspondence do
  it "materializes an email from the raw source" do
    mail = Mail.new
    mail.from = 'sender@example.com'
    mail.to = 'recipient@example.com'
    mail.subject = 'hello'
    mail.body = 'world'

    correspondence = Correspondence.new
    correspondence.sender = 'sender@example.com'
    correspondence.recipients = 'recipient@example.com'
    correspondence.subject = 'hello'
    correspondence.body = 'world'
    correspondence.raw_source = mail.to_s

    materialized_mail = correspondence.materialized_mail
    expect(materialized_mail.from).to eq([correspondence.sender])
    expect(materialized_mail.to).to eq([correspondence.recipients])
    expect(materialized_mail.subject).to eq(correspondence.subject)
    expect(materialized_mail.body.to_s).to eq(correspondence.body)
  end
end
