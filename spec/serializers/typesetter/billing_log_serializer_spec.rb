require 'rails_helper'

describe Typesetter::BillingLogSerializer do
  before do
    CardLoader.load('PlosBilling::BillingTask')
  end

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
      short_title: 'my paper short',
      accepted_at: Time.now.utc
    )
  end

  let(:billing_task) do
    FactoryGirl.create(:billing_task, :with_card_content, paper: paper)
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

  it 'has a ned_id for a pre-existing billing user' do
    FactoryGirl.create(:user, email: paper.answer_for('plos_billing--email').value, ned_id: '12345')
    expect(output[:ned_id]).to eq(12345)
  end

  it 'does not have a ned_id for a billing user that does not exist' do
    expect(output[:ned_id]).to be_nil
  end

  describe 'pulls information from the paper' do
    it 'has a default output' do
      aggregate_failures("default output checks") do
        expect(output[:corresponding_author_ned_id]).to eq(paper.creator.ned_id), 'has a corresponding_author_ned_id based upon the ned_id of the paper creator'
        expect(output[:corresponding_author_ned_email]).to eq(paper.creator.email), 'has a corresponding_author_ned_email based upon the ned email of the paper creator'
        expect(output[:documentid]).to eq(paper.id), 'has documentid which is the manuscript id'
        expect(output[:date_first_entered_production]).to eq(paper.accepted_at), 'has date_first_entered_production which is date paper was accepted'
        expect(output[:dtitle]).to eq(paper.title), 'has a title which is the paper title'
        expect(output[:journal]).to eq(paper.journal.name), 'has journal equal to the journal name'
      end
    end

    it 'has first_submitted_at' do
      paper.initial_submit! paper.creator
      expect(output[:original_submission_start_date]).to eq(paper.first_submitted_at)
    end
  end

  context 'pulls from corresponding billing task that' do
    it 'has middlename if the field exists' do
      # This spec will fail if middle_name becomes a field on the billing task
      # At that point the serializer should be updated
      if billing_task.answer_for('plos_billing--middle_name').present?
        expect(output[:middlename]).to eq(billing_task.answer_for('plos_billing--middle_name').value)
      end
    end

    it "aggregates information from the billing task" do
      aggregate_failures("default output") do
        expect(output[:firstname]).to eq(billing_task.answer_for('plos_billing--first_name').value), 'has the first name'
        expect(output[:lastname]).to eq(billing_task.answer_for('plos_billing--last_name').value), 'has lastname'
        expect(output[:title]).to eq(billing_task.answer_for('plos_billing--title').value), 'has title'
        expect(output[:institute]).to eq(billing_task.answer_for('plos_billing--affiliation1').value), 'has institute'
        expect(output[:department]).to eq(billing_task.answer_for('plos_billing--department').value), 'has department'
        expect(output[:address1]).to eq(billing_task.answer_for('plos_billing--address1').value), 'has address1'
        expect(output[:address2]).to eq(billing_task.answer_for('plos_billing--address2').value), 'has address2'
        expect(output[:city]).to eq(billing_task.answer_for('plos_billing--city').value), 'has city'
        expect(output[:state]).to eq(billing_task.answer_for('plos_billing--state').value), 'has state'
        expect(output[:zip]).to eq(billing_task.answer_for('plos_billing--postal_code').value), 'has zip'
        expect(output[:country]).to eq(billing_task.answer_for('plos_billing--country').value), 'has country'
        expect(output[:phone1]).to eq(billing_task.answer_for('plos_billing--phone_number').value), 'has phone1'
        expect(output[:email]).to eq(billing_task.answer_for('plos_billing--email').value), 'has email'

        expect(output[:direct_bill_response]).to be_nil, 'does not have a direct_bill_response when the payment method is not institutional'
        expect(output[:gpi_response]).to be_nil, 'does not have a gpi_response when the payment method is not gpi'

        expect(output[:fundRef]).to eq(financial_disclosure_task.funding_statement), 'has fundRef'

        expect(paper.manuscript_id.split('.').count).to eq(2), 'the paper manuscript id needs to have 2 parts for this next expectation'
        expect(output[:pubdnumber]).to eq(paper.manuscript_id), 'has pubdnumber which is the same as the manuscript_id of the paper'
      end
    end

    it 'has a direct_bill_response when the payment method is institutional' do
      question = CardContent.find_by(ident: 'plos_billing--payment_method')
      question.answers.first.update_column(:value, 'institutional')
      billing_task.answer_for('plos_billing--ringgold_institution').update_column(:additional_data, { 'nav_customer_number' => 'C01010' })
      expect(output[:direct_bill_response]).to eq('C01010')
    end

    it 'has a gpi_response when the payment method is gpi' do
      question = CardContent.find_by(ident: 'plos_billing--payment_method')
      question.answers.first.update_column(:value, 'gpi')
      expect(output[:gpi_response]).to eq(billing_task.answer_for('plos_billing--gpi_country').value)
    end
  end

  it 'has final_dispo_accept which is date the paper was accepted' do
    final_tech_check_task.completed = true
    final_tech_check_task.save
    expect(output[:final_dispo_accept].utc.to_s).to eq(paper.accepted_at.utc.to_s)
  end

  it 'has category' do
    paper.update_column(:paper_type, 'Some Research')
    expect(output[:category]).to eq('Some Research')
  end
end
