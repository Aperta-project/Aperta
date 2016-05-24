require 'rails_helper'

describe Typesetter::BillingLogSerializer do
  subject(:serializer) { described_class.new(paper) }
  let(:output) { serializer.serializable_hash }
  let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }
  let(:other_paper) { create(:paper) }
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_academic_editor_user,
      :with_short_title,
      :with_creator,
      journal: journal,
      short_title: 'my paper short'
    )
  end

  let(:billing_task) do
    FactoryGirl.create(:billing_task, :with_nested_question_answers, paper: paper)
  end

  let(:financial_disclosure_task) do
    FactoryGirl.create(:financial_disclosure_task, paper: paper)
  end

  let(:final_tech_check_task) do
    FactoryGirl.create(:final_tech_check_task, paper: paper)
  end

  before do
    paper.phases.first.tasks.push(*[billing_task,
                                    financial_disclosure_task,
                                    final_tech_check_task])
  end

  describe 'doi' do
    let(:our_task) do
      paper_task.call('PlosBilling::BillingTask')
    end

    it 'has doi' do
      paper.doi = '1234'
      output = serializer.serializable_hash
      expect(output[:doi]).to eq('1234')
    end
  end

  it 'has a guid for a pre-existing billing user guid' do
    FactoryGirl.create(:user, email: 'bob@example.com', em_guid: 'PONE-1234')
    expect(output[:guid]).to eq('PONE-1234')
  end

  it 'has documentid which is the manuscript id' do
    expect(output[:documentid]).to eq(paper.id)
  end

  it 'has first_submitted_at' do
    paper.initial_submit!
    expect(output[:original_submission_start_date]).to eq(paper.first_submitted_at)
  end

  it 'has date_first_entered_production which is date paper was accepted' do
    expect(output[:date_first_entered_production]).to eq(paper.accepted_at)
  end

  it 'has dtitle which is the paper title' do
    expect(output[:dtitle]).to eq(paper.title)
  end

  it 'has journal_id' do
    expect(output[:journal_id]).to eq(paper.journal.id)
  end

  context 'pulls from corresponding billing task that' do
    it 'has the first name' do
      expect(output[:firstname]).to eq(billing_task.answer_for('plos_billing--first_name').value)
    end

    it 'has middlename if the field exists' do
      # This spec will fail if middle_name becomes a field on the billing task
      # At that point the serializer should be updated
      if billing_task.answer_for('plos_billing--middle_name').present?
        expect(output[:middlename]).to eq(billing_task.answer_for('plos_billing--middle_name').value)
      end
    end

    it 'has lastname' do
      expect(output[:lastname]).to eq(billing_task.answer_for('plos_billing--last_name').value)
    end

    it 'has title' do
      expect(output[:title]).to eq(billing_task.answer_for('plos_billing--title').value)
    end

    it 'has institute' do
      expect(output[:institute]).to eq(billing_task.answer_for('plos_billing--affiliation1').value)
    end

    it 'has department' do
      expect(output[:department]).to eq(billing_task.answer_for('plos_billing--department').value)
    end

    it 'has address1' do
      expect(output[:address1]).to eq(billing_task.answer_for('plos_billing--address1').value)
    end

    it 'has address2' do
      expect(output[:address2]).to eq(billing_task.answer_for('plos_billing--address2').value)
    end

    it 'has city' do
      expect(output[:city]).to eq(billing_task.answer_for('plos_billing--city').value)
    end

    it 'has state' do
      expect(output[:state]).to eq(billing_task.answer_for('plos_billing--state').value)
    end

    it 'has zip' do
      expect(output[:zip]).to eq(billing_task.answer_for('plos_billing--postal_code').value)
    end

    it 'has country' do
      expect(output[:country]).to eq(billing_task.answer_for('plos_billing--country').value)
    end

    it 'has phone1' do
      expect(output[:phone1]).to eq(billing_task.answer_for('plos_billing--phone_number').value)
    end

    it 'has email' do
      expect(output[:email]).to eq(billing_task.answer_for('plos_billing--email').value)
    end

    it 'has a direct_bill_response when the payment method is institutional' do
      question = NestedQuestion.find_by(ident: 'plos_billing--payment_method')
      question.nested_question_answers.first.update_column(:value, 'institutional')
      expect(output[:direct_bill_response]).to eq(billing_task.answer_for('plos_billing--ringgold_institution').value)
    end

    it 'does not have a direct_bill_response when the payment method is not institutional' do
      expect(output[:direct_bill_response]).to be_nil
    end

    it 'has a gpi_response when the payment method is gpi' do
      question = NestedQuestion.find_by(ident: 'plos_billing--payment_method')
      question.nested_question_answers.first.update_column(:value, 'gpi')
      expect(output[:gpi_response]).to eq(billing_task.answer_for('plos_billing--gpi_country').value)
    end

    it 'does not have a gpi_response when the payment method is not gpi' do
      expect(output[:gpi_response]).to be_nil
    end
  end

  it 'has pubdnumber which is the same as manuscript id' do
    expect(output[:pubdnumber]).to eq(paper.id)
  end

  it 'has fundRef' do
    expect(output[:fundRef]).to eq(financial_disclosure_task.funding_statement)
  end

  it 'has final_dispo_accept which is date FTC was completed' do
    final_tech_check_task.completed = true
    final_tech_check_task.save
    expect(output[:final_dispo_accept].utc.to_s).to eq(final_tech_check_task.completed_at.utc.to_s)
  end

  it 'has category' do
    paper.update_column(:paper_type, 'Some Research')
    expect(output[:category]).to eq('Some Research')
  end
end
