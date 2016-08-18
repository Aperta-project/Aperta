require 'rails_helper'

describe Typesetter::MetadataSerializer do
  subject(:serializer) { described_class.new(paper) }
  let(:output) { serializer.serializable_hash }
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_academic_editor_role,
      :with_creator_role
    )
  end
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :accepted,
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

  let(:our_question) do
    # expects `our_task` to be defined within a `describe` block
    lambda do |question_ident|
      our_task.nested_questions.find_by_ident(question_ident)
    end
  end

  before do
    paper.phases.first.tasks.push(*metadata_tasks)
  end

  it 'serializes authors in order' do
    paper = FactoryGirl.create(
      :paper,
      :accepted,
      journal: journal
    )
    author = FactoryGirl.create(:author, paper: paper)
    author2 = FactoryGirl.create(:author, paper: paper)
    paper.authors = [author, author2]
    group_author = FactoryGirl.create(:group_author, paper: paper)
    paper.group_authors = [group_author]
    first_author = AuthorListItem.new(
      position: 1,
      author_id: group_author.id,
      author_type: "GroupAuthor",
      paper_id: paper.id)
    first_author.save!
    second_author = AuthorListItem.new(
      position: 2,
      author_id: author.id,
      author_type: "Author",
      paper_id: paper.id)
    second_author.save!
    third_author = AuthorListItem.new(
      position: 3,
      author_id: author2.id,
      author_type: "Author",
      paper_id: paper.id)
    third_author.save!
    output = Typesetter::MetadataSerializer.new(paper).serializable_hash

    expect(output[:authors][0][:author][:name]).to eq(group_author.name)
    expect(output[:authors][1][:author][:first_name]).to eq(author.first_name)
    expect(output[:authors][2][:author][:first_name]).to eq(author2.first_name)
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

  it 'has abstract' do
    paper.abstract = 'here is the abstract'
    expect(output[:paper_abstract]).to eq('here is the abstract')
  end

  describe 'publication_date' do
    let(:our_task) do
      paper.tasks.find_by(
        type: 'TahiStandardTasks::ProductionMetadataTask'
      ).first!
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

  describe 'related articles' do
    let!(:unincluded_article) do
      FactoryGirl.create(:related_article, linked_title: "Unsendable", paper: paper, send_link_to_apex: false)
    end

    context "the paper has no related articles to be sent to apex" do
      it "has an empty related_articles array" do
        expect(output[:related_articles]).to eq([])
      end
    end

    context "the paper has a related article to be sent to apex" do
      let!(:included_article) do
        FactoryGirl.create(:related_article,
                           linked_title: "Sendable",
                           linked_doi: "some.doi",
                           paper: paper,
                           send_link_to_apex: true)
      end

      let(:related_articles) { output[:related_articles] }

      let(:serialized_included_article) do
        Typesetter::RelatedArticleSerializer
          .new(included_article)
          .serializable_hash
      end

      it "includes the linked_doi and linked_title where send_link_to_apex=true" do
        expect(related_articles).to eql([serialized_included_article])
      end
    end
  end

  shared_examples_for 'serializes :has_one paper task' do |opts|
    opts[:factory] || fail(ArgumentError, 'Must pass in a :factory')
    opts[:serializer] || fail(ArgumentError, 'Must pass in a :serializer')
    opts[:json_key] || fail(ArgumentError, 'Must pass in a :json_key')

    context 'with the task' do
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

    context 'without the task' do
      let(:task) { nil }

      it 'has the task in the output with a nil value' do
        expect(output.fetch(opts[:json_key])).to be_kind_of(Hash)
      end
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
    it_behaves_like(
      'serializes :has_many property',
      property: :academic_editors,
      factory: :user,
      serializer: Typesetter::EditorSerializer,
      json_key: :academic_editors
    )
  end

  context 'competing_interests' do
    it_behaves_like(
      'serializes :has_one paper task',
      factory: :competing_interests_task,
      serializer: Typesetter::CompetingInterestsSerializer,
      json_key: :competing_interests
    )
  end

  context 'data_availability' do
    it_behaves_like(
      'serializes :has_one paper task',
      factory: :data_availability_task,
      serializer: Typesetter::DataAvailabilitySerializer,
      json_key: :data_availability
    )
  end

  context 'financial_disclosure' do
    it_behaves_like(
      'serializes :has_one paper task',
      factory: :financial_disclosure_task,
      serializer: Typesetter::FinancialDisclosureSerializer,
      json_key: :financial_disclosure
    )
  end

  context 'authors' do
    it_behaves_like(
      'serializes :has_many property',
      property: :author_list_items,
      factory: :author,
      serializer: Typesetter::AuthorListItemSerializer,
      json_key: :authors
    )
  end

  context 'supporting_information_files' do
    it_behaves_like(
      'serializes :has_many property',
      property: :supporting_information_files,
      message_chain: 'supporting_information_files.publishable',
      factory: :supporting_information_file,
      serializer: Typesetter::SupportingInformationFileSerializer,
      json_key: :supporting_information_files
    )
  end

  context 'and the paper is accepted' do
    before { paper.publishing_state = 'accepted' }

    it 'serializes without error' do
      expect(output).to_not be_empty
    end
  end

  context 'and the paper is not accepted' do
    before { paper.publishing_state = 'unsubmitted' }

    it 'raise an error' do
      expect { output }.to raise_error(
        Typesetter::MetadataError,
        /Paper has not been accepted/
      )
    end
  end
end
