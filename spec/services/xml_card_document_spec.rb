require 'rails_helper'

describe XmlCardDocument::XmlValidationError do
  it 'parses ActiveModel:Errors messages' do
    errors = double('ActiveModel::Errors', full_messages: ['content type is invalid'])
    xml_validation = XmlCardDocument::XmlValidationError.new(errors)
    expect(xml_validation.message[0][:message]).to be == 'content type is invalid'
  end

  it 'parses custom errors' do
    errors = [{ message: 'invalid versions', line: '1', column: '1' }]
    xml_validation = XmlCardDocument::XmlValidationError.new(errors)
    expect(xml_validation.message[0][:message]).to be == 'invalid versions'
  end
end
