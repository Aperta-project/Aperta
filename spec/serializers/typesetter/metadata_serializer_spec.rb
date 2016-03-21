require 'rails_helper'

describe Typesetter::MetadataSerializer do
  subject(:serializer) { described_class.new(paper) }
  let(:output) { serializer.serializable_hash }
  let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_academic_editor_user,
      :with_short_title,
      journal: journal,
      short_title: 'my paper short'
    )
  end
  let(:metadata_tasks) do
    [
      FactoryGirl.create(:competing_interests_task, paper: paper),
      FactoryGirl.create(:data_availability_task, paper: paper),
      FactoryGirl.create(:financial_disclosure_task, paper: paper),
      FactoryGirl.create(:production_metadata_task, paper: paper),
      FactoryGirl.create(:publishing_related_questions_task, paper: paper)
    ]
  end

  let(:paper_task) do
    ->(task_type) { paper.tasks.find_by_type(task_type) }
  end

  let(:our_question) do
    # expects `our_task` to be defined within a `describe` block
    lambda do |question_ident|
      our_task.nested_questions.find_by_ident(question_ident)
    end
  end

  before do
    paper.phases.first.tasks.push(*metadata_tasks)
  end

  it 'has short_title' do
    expect(output[:short_title]).to eq('my paper short')
  end

  it 'has doi' do
    paper.doi = '1234'
    expect(output[:doi]).to eq('1234')
  end

  it 'has manuscript_id' do
    allow(paper).to receive(:manuscript_id).and_return '1234'
    expect(output[:manuscript_id]).to eq('1234')
  end

  it 'has paper_type' do
    paper.paper_type = 'Pandas'
    expect(output[:paper_type]).to eq('Pandas')
  end

  it 'has journal_title' do
    paper.journal.name = 'Pandas'
    expect(output[:journal_title]).to eq('Pandas')
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

  describe 'publication_date' do
    let(:our_task) do
      paper_task.call('TahiStandardTasks::ProductionMetadataTask')
    end

    context "with valid date" do
      before do
        allow_any_instance_of(TahiStandardTasks::ProductionMetadataTask)
          .to receive(:publication_date).and_return("11/16/2015")
      end

      it 'has a date' do
        expect(output[:publication_date]).to eq(Date.new(2015, 11, 16))
      end
    end

    context "with no date" do
      before do
        allow_any_instance_of(TahiStandardTasks::ProductionMetadataTask)
          .to receive(:publication_date).and_return(nil)
      end

      it 'accepts no publication date' do
        expect(output[:publication_date]).to be_nil
      end
    end
  end

  shared_examples_for 'serializes :has_one paper task' do |opts|
    opts[:factory] || fail(ArgumentError, 'Must pass in a :factory')
    opts[:serializer] || fail(ArgumentError, 'Must pass in a :serializer')
    opts[:json_key] || fail(ArgumentError, 'Must pass in a :json_key')

    let(:task) do
      FactoryGirl.create(opts[:factory], phase: paper.phases.first)
    end
    let(:fake_serialized_data) { 'Fake serialized data' }
    let(:fake_instance_double) do
      instance_double(
        "#{opts[:serializer]}",
        serializable_hash: fake_serialized_data
      )
    end

    before do
      expect(opts[:serializer]).to receive(:new).and_return fake_instance_double
    end

    it "serializes the #{opts[:json_key]} using the #{opts[:serializer]}" do
      actual_output = output[opts[:json_key]]
      expect(actual_output).to eq(fake_serialized_data)
    end
  end

  shared_examples_for 'serializes :has_many property' do |opts|
    opts[:property] || fail(ArgumentError, 'Must pass in a :property')
    opts[:factory] || fail(ArgumentError, 'Must pass in a :factory')
    opts[:serializer] || fail(ArgumentError, 'Must pass in a :serializer')
    opts[:json_key] || fail(ArgumentError, 'Must pass in a :json_key')

    let(:has_many_property_value) do
      [FactoryGirl.build(opts[:factory])]
    end
    let(:fake_serialized_data) { 'Fake serialized data' }
    let(:fake_instance_double) do
      instance_double(
        "#{opts[:serializer]}",
        serializable_hash: fake_serialized_data
      )
    end

    before do
      expected_message = opts[:message_chain] || opts[:property]
      allow(paper).to receive_message_chain(expected_message)
        .and_return has_many_property_value
      expect(opts[:serializer]).to receive(:new).and_return fake_instance_double
    end

    it "serializes the #{opts[:json_key]} using the #{opts[:serializer]}" do
      actual_output = output[opts[:json_key]]
      expect(actual_output).to eq([fake_serialized_data])
    end
  end

  context 'academic_editors' do
    include_examples(
      'serializes :has_many property',
      property: :academic_editors,
      factory: :user,
      serializer: Typesetter::EditorSerializer,
      json_key: :academic_editors
    )
  end

  context 'competing_interests' do
    include_examples(
      'serializes :has_one paper task',
      factory: :competing_interests_task,
      serializer: Typesetter::CompetingInterestsSerializer,
      json_key: :competing_interests
    )
  end

  context 'data_availability' do
    include_examples(
      'serializes :has_one paper task',
      factory: :data_availability_task,
      serializer: Typesetter::DataAvailabilitySerializer,
      json_key: :data_availability
    )
  end

  context 'financial_disclosure' do
    include_examples(
      'serializes :has_one paper task',
      factory: :financial_disclosure_task,
      serializer: Typesetter::FinancialDisclosureSerializer,
      json_key: :financial_disclosure
    )
  end

  context 'authors' do
    include_examples(
      'serializes :has_many property',
      property: :authors,
      factory: :author,
      serializer: Typesetter::AuthorSerializer,
      json_key: :authors
    )
  end

  context 'supporting_information_files' do
    include_examples(
      'serializes :has_many property',
      property: :supporting_information_files,
      message_chain: 'supporting_information_files.publishable',
      factory: :supporting_information_file,
      serializer: Typesetter::SupportingInformationFileSerializer,
      json_key: :supporting_information_files
    )
  end
end
