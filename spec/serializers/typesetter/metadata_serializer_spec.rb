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
      short_title: '<p>my <pre><span>paper</span></pre> <u><span style="omg: so-much-garbage\">short</span></u></p>'
    )
  end
  let(:early_posting_task) { FactoryGirl.create(:early_posting_task, paper: paper) }
  let(:metadata_tasks) do
    [
      FactoryGirl.create(:competing_interests_task, paper: paper),
      FactoryGirl.create(:data_availability_task, paper: paper),
      FactoryGirl.create(:financial_disclosure_task, paper: paper),
      FactoryGirl.create(:production_metadata_task, paper: paper),
      FactoryGirl.create(:publishing_related_questions_task, paper: paper),
      early_posting_task
    ]
  end
  let(:our_question) do
    # expects `our_task` to be defined within a `describe` block
    lambda do |question_ident|
      our_task.card.content_for_version_without_root(:latest).find_by_ident(question_ident)
    end
  end
  let!(:apex_html_flag) { FactoryGirl.create :feature_flag, name: "KEEP_APEX_HTML", active: false }

  before do
    FactoryGirl.create :feature_flag, name: "CORRESPONDING_AUTHOR", active: true
    CardLoader.load('TahiStandardTasks::EarlyPostingTask')
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

  it 'strips base stuff from short_titles' do
    expect(paper.short_title).to match(/<p>/)
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

  it 'strips bad stuff from title' do
    paper.title = '<p><span>here</span> <u>is</u> <pre>the</pre> title</p>'
    expect(output[:paper_title]).to eq('here is the title')
  end

  it 'has abstract' do
    paper.abstract = 'here is the abstract'
    expect(output[:paper_abstract]).to eq('here is the abstract')
  end

  describe 'early_article_posting' do
    context 'with an answer' do
      let!(:answer) do
        card_content = CardContent.where(ident: 'early-posting--consent').first
        FactoryGirl.create(:answer, card_content: card_content, owner: early_posting_task, value: answer_value)
      end
      context 'that is true' do
        let(:answer_value) { true }
        it 'has early_article_posting information' do
          expect(output[:early_article_posting]).to eq(answer_value)
        end
      end
      context 'that is false' do
        let(:answer_value) { false }
        it 'has early_article_posting information' do
          expect(output[:early_article_posting]).to eq(answer_value)
        end
      end
    end

    context 'without an answer' do
      it 'has early_article_posting information' do
        expect(output[:early_article_posting]).to eq(false)
      end
    end
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
                           linked_title: "<a><b>Sendable</b></a>",
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

  describe "add custom card and export the fields" do
    let(:journal) do
      FactoryGirl.create(:journal, :with_creator_role, pdf_css: 'body { background-color: red; }')
    end
    let(:paper) { FactoryGirl.create(:paper, :with_phases, :version_with_file_type, :with_creator, journal: journal) }
    let(:card_version) { FactoryGirl.create(:card_version) }
    let(:another_card_version) { FactoryGirl.create(:card_version) }
    let(:my_custom_task) { FactoryGirl.create(:custom_card_task, card_version: card_version, paper: paper) }
    let(:another_my_custom_task) { FactoryGirl.create(:custom_card_task, card_version: another_card_version, paper: paper) }
    before do
      parent = card_version.content_root
      parent.children << [FactoryGirl.create(:card_content, parent: parent, card_version: card_version, ident: "my_custom_task--some_text", value_type: 'text', default_answer_value: 'This is my anwser'),
                          FactoryGirl.create(:card_content, parent: parent, card_version: card_version, ident: "my_custom_task--question_1", value_type: 'boolean', default_answer_value: 'true'),
                          FactoryGirl.create(:card_content, parent: parent, card_version: card_version, ident: "my_custom_task--question_2", value_type: 'boolean', default_answer_value: 'false')]
      card_version.create_default_answers(my_custom_task)
      parent = another_card_version.content_root
      parent.children << [FactoryGirl.create(:card_content, parent: parent, card_version: another_card_version, ident: "another_custom_task--some_text", value_type: 'text', default_answer_value: 'This is my other anwser'),
                          FactoryGirl.create(:card_content, parent: parent, card_version: another_card_version, ident: "another_custom_task--question_1", value_type: 'boolean', default_answer_value: 'false'),
                          FactoryGirl.create(:card_content, parent: parent, card_version: another_card_version, ident: "another_custom_task--question_2", value_type: 'boolean', default_answer_value: 'false')]
      another_card_version.create_default_answers(another_my_custom_task)
      paper.publishing_state = 'accepted'
    end

    it "check exported custom card fields" do
      parsed_metadata = JSON.parse(Typesetter::MetadataSerializer.new(paper).to_json)
      expected_metadata = { "my_custom_task--some_text" => 'This is my anwser',
                            "my_custom_task--question_1" => true,
                            "my_custom_task--question_2" => false,
                            "another_custom_task--some_text" => 'This is my other anwser',
                            "another_custom_task--question_1" => false,
                            "another_custom_task--question_2" => false }
      expect(parsed_metadata['metadata']['custom_card_fields']).to eq expected_metadata
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
end
