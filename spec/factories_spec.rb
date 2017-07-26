require 'rails_helper'

describe "task factory record creation" do
  it "create minimal number of Journals" do
    FactoryGirl.create(:ad_hoc_task)
    expect(Journal.count).to eq(1)
  end

  it "creates minimal Manuscript Manager Templates" do
    FactoryGirl.create(:ad_hoc_task)
    expect(ManuscriptManagerTemplate.count).to eq(1)
  end

  it "creates minimal number of Papers" do
    FactoryGirl.create(:ad_hoc_task)
    expect(Paper.count).to eq(1)
  end

  it "creates correct Paper relationships" do
    paper = FactoryGirl.create(:paper)
    task = FactoryGirl.create(:ad_hoc_task, paper: paper)
    expect(task.phase.paper).to eq(paper)
  end

  it "creates correct Paper relationship through Phase" do
    task = FactoryGirl.create(:ad_hoc_task)
    expect(task.phase.paper).to eq(task.paper)
  end

  it "creates correct Journal relationships" do
    task = FactoryGirl.create(:ad_hoc_task)
    paper_journal = task.phase.paper.journal
    card_journal = task.card_version.card.journal
    expect(paper_journal).to eq(card_journal)
  end
end

describe "paper factory record creation" do
  it "creates minimal number of Journals" do
    FactoryGirl.create(:paper)
    expect(Journal.count).to eq(1)
  end

  it "with integration journal creates minimal number of Journals" do
    FactoryGirl.create(:paper, :with_integration_journal)
    expect(Journal.count).to eq(1)
  end

  it "with phases creates minimal number of Journals" do
    FactoryGirl.create(:paper, :with_phases)
    expect(Journal.count).to eq(1)
  end

  it "with tasks creates minimal number of Journals" do
    FactoryGirl.create(:paper, :with_tasks)
    expect(Journal.count).to eq(1)
  end
end
