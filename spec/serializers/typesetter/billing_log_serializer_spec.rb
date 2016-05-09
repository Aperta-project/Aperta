require 'rails_helper'

describe Typesetter::BillingLogSerializer do
  subject(:serializer) { described_class.new(paper) }
  let(:output) { serializer.serializable_hash }
  let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }
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
  let(:metadata_tasks) do
    [
      FactoryGirl.create(:authors_task, paper: paper),
      FactoryGirl.create(:competing_interests_task, paper: paper),
      FactoryGirl.create(:data_availability_task, paper: paper),
      FactoryGirl.create(:financial_disclosure_task, paper: paper),
      FactoryGirl.create(:production_metadata_task, paper: paper),
      FactoryGirl.create(:publishing_related_questions_task, paper: paper),
      FactoryGirl.create(:billing_task, paper: paper)
    ]
  end

  let(:paper_task) do
    ->(task_type) { paper.tasks.find_by_type(task_type) }
  end
  # describe 'publication_date' do
  #   let(:our_task) do
  #     paper_task.call('TahiStandardTasks::ProductionMetadataTask')
  #   end
  let(:our_question) do
    # expects `our_task` to be defined within a `describe` block
    lambda do |question_ident|
      our_task.nested_questions.find_by_ident(question_ident)
    end
  end

  before do
    paper.phases.first.tasks.push(*metadata_tasks)
  end

  describe 'doi' do
    let(:our_task) do
      paper_task.call('PlosBilling::BillingTask')
    end

    before do
    end

    it 'has doi' do
      paper.doi = '1234'
      output = serializer.serializable_hash
      expect(output[:doi]).to eq('1234')
    end
  end

  it 'has manuscript_id' do
    allow(paper).to receive(:manuscript_id).and_return '1234'
    expect(output[:manuscript_id]).to eq('1234')
  end

  it 'has paper_type' do
    paper.paper_type = 'Pandas'
    expect(output[:paper_type]).to eq('Pandas')
  end

  it 'has first_submitted_at' do
    now = Time.zone.now
    paper.update_attribute(:first_submitted_at, now)
    expect(output[:received_date]).to eq(now)
  end

  it 'has accepted_at' do
    now = Time.zone.now
    paper.update_attribute(:accepted_at, now)
    expect(output[:accepted_date]).to eq(now)
  end

  it 'has title' do
    paper.title = 'here is the title'
    expect(output[:paper_title]).to eq('here is the title')
  end

  it 'has journal_id' do
    paper.journal_id = '1234'
    expect(output[:journal_id]).to eq('1234')
  end

  it 'has firstname' do
    paper.firstname = 'Foo'
    expect(output[:firstname]).to eq('Foo')
  end

  it 'has middlename' do
    paper.middlename = 'Biz'
    expect(output[:middlename]).to eq('Biz')
  end

  it 'has lastname' do
    paper.lastname = 'Buz'
    expect(output[:lastname]).to eq('Buz')
  end

  it 'has institute' do
    paper.institute = 'Sample Institute'
    expect(output[:institute]).to eq('Sample Institute')
  end

  it 'has department' do
    paper.department = 'Sample Department'
    expect(output[:department]).to eq('Sample Department')
  end

  it 'has address1' do
    paper.address1 = '42 Wallaby Way, Sydney'
    expect(output[:address1]).to eq('42 Wallaby Way, Sydney')
  end

  it 'has address2' do
    paper.address2 = '742 Evergreen Terrace'
    expect(output[:address2]).to eq('742 Evergreen Terrace')
  end

  it 'has address3' do
    paper.address3 = '1600 Pennsylvania Ave NW'
    expect(output[:address3]).to eq('1600 Pennsylvania Ave NW')
  end

  it 'has city' do
    paper.city = 'Sacramento'
    expect(output[:city]).to eq('Sacramento')
  end

  it 'has state' do
    paper.state = 'California'
    expect(output[:state]).to eq('California')
  end

  it 'has zip' do
    paper.zip = '54321'
    expect(output[:zip]).to eq('54321')
  end

  it 'has country' do
    paper.country = 'United States'
    expect(output[:country]).to eq('United States')
  end

  it 'has phone1' do
    paper.phone1 = '3214567'
    expect(output[:phone1]).to eq('3214567')
  end

  it 'has phone2' do
    paper.phone2 = '4561234'
    expect(output[:phone2]).to eq('4561234')
  end

  it 'has fax' do
    paper.fax = '7894321'
    expect(output[:fax]).to eq('7894321')
  end

  it 'has email' do
    paper.email = 'user@domain.com'
    expect(output[:email]).to eq('user@domain.com')
  end

  it 'has pubdnumber' do
    paper.pubdnumber = 'This is a sample pubdnumber'
    expect(output[:pubdnumber]).to eq('This is a sample pubdnumber')
  end

  it 'has dtitle' do
    paper.dtitle = 'This is a sample dtitle'
    expect(output[:dtitle]).to eq('This is a sample dtitle')
  end

  it 'has fundRef' do
    paper.fundRef = 'This is a sample fundRef'
    expect(output[:fundRef]).to eq('This is a sample fundRef')
  end

  it 'has collectionID' do
    paper.collectionID = '54321'
    expect(output[:collectionID]).to eq('54321')
  end

  it 'has collection' do
    paper.collection = 'This is a sample collection'
    expect(output[:collection]).to eq('This is a sample collection')
  end

  it 'has direct_bill_response' do
    paper.direct_bill_response = 'This is a sample direct_bill_response'
    expect(output[:direct_bill_response]).to eq('This is a sample direct_bill_response')
  end

  it 'has gpi_response' do
    paper.gpi_response = 'This is a sample gpi_response'
    expect(output[:gpi_response]).to eq('This is a sample gpi_response')
  end

  it 'has final_dispo_accept' do
    paper.final_dispo_accept = 'This is a sample final_dispo_accept'
    expect(output[:final_dispo_accept]).to eq('This is a sample final_dispo_accept')
  end

  it 'has category' do
    paper.category = 'This is a sample category'
    expect(output[:category]).to eq('This is a sample category')
  end

  it 'has s3_url' do
    paper.s3_url = 'https://s3-eu-west-1.amazonaws.com/foo/bar'
    expect(output[:s3_url]).to eq('https://s3-eu-west-1.amazonaws.com/foo/bar')
  end
end
