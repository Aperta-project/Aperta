require 'rails_helper'

# Example class used to demonstrate AuthorsList inclusion
class ExampleAuthorsListInclude
  include AuthorsList
  attr_reader :paper
  def initialize(paper)
    @paper = paper
  end
end

describe AuthorsList do
  let!(:paper) { FactoryGirl.create :paper }
  let!(:author1) { FactoryGirl.create :author, paper: paper }
  let!(:author2) { FactoryGirl.create :author, paper: paper }
  let!(:model) { ExampleAuthorsListInclude.new(paper) }

  before do
    # allow(model).to_receive(:paper) { paper }
    author1.position = 1
    author2.position = 2
    author1.save
    author2.save
  end

  it "returns authors' last name, first name and affiliation name in an ordered list" do
    expect(model.authors_list).to eq "1. #{author1.last_name}, #{author1.first_name} from #{author1.affiliation}\n2. #{author2.last_name}, #{author2.first_name} from #{author2.affiliation}"
  end

  it "only includes `from $affiliation` when author has an affiliation" do
    author2.update_attributes(affiliation: nil)
    expect(model.authors_list).to eq "1. #{author1.last_name}, #{author1.first_name} from #{author1.affiliation}\n2. #{author2.last_name}, #{author2.first_name}"
  end
end
