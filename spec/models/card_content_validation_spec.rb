require 'rails_helper'

describe CardContentValidation do

  context 'validate' do
    context '#validate_by_string_match' do
      subject(:card_content_validation) { FactoryGirl.create(:card_content_validation,
                                                            :with_string_match_validation, validator: 'org') }
      let(:card) { FactoryGirl.create(:card, card_contents: [card_content]) }
      let(:answer) { FactoryGirl.create(:answer, :with_task_owner, value: 'corgi')}
      let!(:card_content) { FactoryGirl.create(:card_content, answers: [answer], card_content_validations: [card_content_validation]) }

      it 'is valid if the string matches' do
        expect(card_content_validation.validate_answer(answer)).to eq true
      end

      it 'is invalid if the string doesnt match' do
        answer.update!(value: 'eskie')
        expect(card_content_validation.validate_answer(answer)).to eq false
      end
    end
  end
  
end
