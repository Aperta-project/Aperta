require 'rails_helper'

describe TahiStandardTasks::LetterTemplate do
  subject(:template){ described_class.new(salutation:salutation, body:body) }
  let(:salutation){ "Dear SoAndSo," }
  let(:body){ "You've won a million dollars!" }

  it "has a salutation" do
    expect(template.salutation).to eq(salutation)
  end

  it "has a body" do
    expect(template.body).to eq(body)
  end

  it "can be returned as_json" do
    expect(template.as_json).to eq(salutation:salutation, body:body)
  end

  it "can be converted to_json" do
    expect(template.to_json).to eq({salutation:salutation, body:body}.to_json)
  end
end
