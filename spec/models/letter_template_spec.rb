require 'rails_helper'

describe LetterTemplate do
  describe 'validations' do
    [:letter, :subject].each do |attr_key|
      it "should require a #{attr_key.to_s}" do
        letter_template = FactoryGirl.build(:letter_template, attr_key => '')
        expect(letter_template).not_to be_valid
      end
    end
  end
end
