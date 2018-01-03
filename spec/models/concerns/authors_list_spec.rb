require 'rails_helper'

describe TahiStandardTasks::AuthorsList do
  let!(:paper) { FactoryGirl.create :paper }
  let!(:author1) do
    FactoryGirl.create :author, paper: paper, first_name: "FirstAuthor"
  end
  let!(:author2) do
    FactoryGirl.create :author, paper: paper, first_name: "SecondAuthor"
  end

  before do
    author1.position = 1
    author2.position = 2
    author1.save
    author2.save
  end

  # rubocop:disable LineLength
  it "returns ordered list of authors last and first name, and affiliation" do
    expect(subject.authors_list(paper)).to eq "1. #{author1.last_name}, #{author1.first_name} from #{author1.affiliation}\n2. #{author2.last_name}, #{author2.first_name} from #{author2.affiliation}"
  end

  it "only includes `from $affiliation` when author has an affiliation" do
    author2.update_attributes(affiliation: nil)
    expect(subject.authors_list(paper)).to eq "1. #{author1.last_name}, #{author1.first_name} from #{author1.affiliation}\n2. #{author2.last_name}, #{author2.first_name}"
  end
  # rubocop:enable LineLength
end
