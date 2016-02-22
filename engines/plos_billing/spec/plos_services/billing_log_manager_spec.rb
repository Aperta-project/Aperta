require 'rails_helper'

describe PlosServices::BillingLogManager do
  let(:paper)   { make_paper }
  let(:bm)      { PlosServices::BillingLogManager.new paper: paper }

  describe "#paper_to_billing_log_hash" do
    it "sets paper's data in the hash" do
      data = bm.paper_to_billing_log_hash

      # if size changes don't forget to add/remove data checks below
      expect(data.size).to                             eq 59

      expect(data[:guid]).to                           eq "PONE-2"
      expect(data[:document_id]).to                    eq paper.manuscript_id
      expect(data[:title]).to                          eq "title"
      expect(data[:first_name]).to                     eq "bob"
      expect(data[:middlename]).to                     eq ""
      expect(data[:lastname]).to                       eq "barker"
      expect(data[:institute]).to                      eq "placeholderInstitute"
      expect(data[:department]).to                     eq "placeholderDepartment"
      expect(data[:address1]).to                       eq "address1"
      expect(data[:address2]).to                       eq "address2"
      expect(data[:address3]).to                       eq ""
      expect(data[:city]).to                           eq "city"
      expect(data[:state]).to                          eq "state"
      expect(data[:zip]).to                            eq "postal_code"
      expect(data[:country]).to                        eq "country"
      expect(data[:phone1]).to                         eq "phone_number"
      expect(data[:phone2]).to                         eq ""
      expect(data[:fax]).to                            eq ""
      expect(data[:email]).to                          eq "email"
      expect(data[:journal]).to                        eq paper.journal.name
      expect(data[:pubdnumber]).to                     eq "placeholderPubDNumber"
      expect(data[:doi]).to                            eq paper.doi
      expect(data[:dtitle]).to                         eq paper.title
      expect(data[:issn]).to                           eq ""
      expect(data[:price]).to                          eq ""
      expect(data[:waiver_text]).to                    eq ""
      expect(data[:discount_institution]).to           eq ""
      expect(data[:collection]).to                     eq ""
      expect(data[:direct_bill]).to                    eq ""
      expect(data[:import_date]).to                    eq ""
      expect(data[:line_no]).to                        eq ""
      expect(data[:original_submission_start_date]).to eq ""
      expect(data[:actual_online_pub_date]).to         eq ""
      expect(data[:batch_no]).to                       eq ""
      expect(data[:exception]).to                      eq ""
      expect(data[:direct_bill_expense]).to            eq ""
      expect(data[:date_first_entered_production]).to  eq ""
      expect(data[:pub_charge_response]).to            eq ""
      expect(data[:pub_waiver_response]).to            eq ""
      expect(data[:institutional_response]).to         eq ""
      expect(data[:gpi_response]).to                   eq ""
      expect(data[:gpi_tier]).to                       eq ""
      expect(data[:base_price]).to                     eq ""
      expect(data[:discount_price]).to                 eq ""
      expect(data[:discount_percent]).to               eq ""
      expect(data[:waiver_amount]).to                  eq ""
      expect(data[:collections_response]).to           eq ""
      expect(data[:eligible]).to                       eq ""
      expect(data[:rescind]).to                        eq ""
      expect(data[:standard_collection_id]).to         eq ""
      expect(data[:terms1]).to                         eq ""
      expect(data[:terms2]).to                         eq ""
      expect(data[:terms3]).to                         eq ""
      expect(data[:terms4]).to                         eq ""
      expect(data[:terms5]).to                         eq ""
      expect(data[:final_dispo_accept]).to             eq "placeholderFinalDispoAccept"
      expect(data[:terms6]).to                         eq ""
      expect(data[:category]).to                       eq "placeholderCategory"
      expect(data[:split]).to                          eq ""
    end
  end

  describe "#to_csv" do
    it "returns a csv obj" do
      csv = bm.to_csv
      expect(csv).to be_a(CSV)

      parsed = CSV.parse(csv.string)
      expect(parsed.first.size).to eq(59)
    end
  end

  describe "#to_s3" do
    it "returns true" do
      expect(bm.to_s3).to be true
    end
  end

  describe "#answer_for" do
    it "returns the questions's answer" do
      expect(bm.send(:answer_for, 'plos_billing--address1')).to eq 'address1'
    end
  end

  def make_paper
    journal = FactoryGirl.create(
      :journal,
      :with_roles_and_permissions,
      :with_doi, { name: 'journal name' }
    )
    paper = FactoryGirl.create :paper_with_task, {
      creator: FactoryGirl.create(:user, { first_name: 'lou', last_name: 'prima', email: 'pfa@pfa.com' }),
      journal: journal,
      short_title: "my title",
      task_params: { title: "Billing", type: "PlosBilling::BillingTask", old_role: "author" }
    }
    make_questions paper
    paper
  end

  def make_questions(paper)
    add_text_question_with_answer(paper, 'plos_billing--address1',      'address1')
    add_text_question_with_answer(paper, 'plos_billing--address2',      'address2')
    add_text_question_with_answer(paper, 'plos_billing--city',          'city')
    add_text_question_with_answer(paper, 'plos_billing--state',         'state')
    add_text_question_with_answer(paper, 'plos_billing--phone_number',  'phone_number')
    add_text_question_with_answer(paper, 'plos_billing--postal_code',   'postal_code')
    add_text_question_with_answer(paper, 'plos_billing--title',         'title')
    add_text_question_with_answer(paper, 'plos_billing--email',         'email')
    add_text_question_with_answer(paper, 'plos_billing--first_name',    'bob')
    add_text_question_with_answer(paper, 'plos_billing--last_name',     'barker')
    add_text_question_with_answer(paper, 'plos_billing--country',       'country')
  end

  def nested_question(ident)
    NestedQuestion.find_by(ident: ident) || FactoryGirl.create(:nested_question, ident: ident, value_type: 'text')
  end

  def add_text_question_with_answer(paper, ident, answer)
    nested_question_answer = FactoryGirl.create(:nested_question_answer, value_type: "text",
      nested_question: nested_question(ident),
      owner: paper.billing_card,
      value: answer,
    )
  end
end
