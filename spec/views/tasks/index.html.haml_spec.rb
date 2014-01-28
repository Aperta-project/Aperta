require 'spec_helper'

describe "tasks/index" do
  let(:paper_title) { nil }

  before do
    paper = Paper.create! title: paper_title, short_title: 'paper short title', journal: Journal.create!
    assign :paper, paper
    assign :task_manager, double(:task_manager, phases: [])
  end

  describe "content for control bar" do
    subject(:content) { render; Capybara.string(view.content_for :control_bar) }

    context "when the paper has a title" do
      let(:paper_title) { 'paper title' }

      it "displays the title as the short title" do
        expect(content.find('#paper-short-title')).to have_text 'paper title'
      end
    end

    context "when the paper does not have a title" do
      it "displays the short title as the short title" do
        expect(content.find('#paper-short-title')).to have_text 'paper short title'
      end
    end
  end
end
