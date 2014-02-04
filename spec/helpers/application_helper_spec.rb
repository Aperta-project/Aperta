require 'spec_helper'

describe ApplicationHelper do

  describe "#active_link_to" do
    context "when the current page is the link target" do
      it "includes an 'active' class" do
        allow(helper).to receive(:current_page?).and_return(true)
        output = helper.active_link_to "Dashboard", '/dashboard'
        expect(output).to eq '<a class="active" href="/dashboard">Dashboard</a>'
      end
    end

    context "when the current page is not the link target" do
      it "does not include an 'active' class" do
        allow(helper).to receive(:current_page?).and_return(false)
        output = helper.active_link_to "Dashboard", '/dashboard'
        expect(output).to eq '<a href="/dashboard">Dashboard</a>'
      end
    end
  end

  before do
    helper.extend Haml
    helper.extend Haml::Helpers
    helper.send :init_haml_helpers
  end

  describe "#card" do
    let(:task) do
      paper = Paper.create! short_title: "foo",
        journal: Journal.create!,
        title: "foo"
      Task.create! title: 'Foo task',
        role: 'some role',
        phase: paper.task_manager.phases.first
    end

    subject(:link) do
      Capybara.string(helper.card task).find 'a'
    end

    specify { expect(link.text.strip).to eq task.title }
    specify { expect(link['href']).to eq paper_task_path(task.paper, task) }
    specify { expect(link['class']).to include 'card' }
    specify { expect(link['class']).to_not include 'completed' }

    it "uses presenter to obtain data attributes" do
      fake_presenter = double(:presenter, data_attributes: { one: 1, two: 2 })
      expect(TaskPresenter).to receive(:for).with(task).and_return fake_presenter
      expect(link['data-one']).to eq "1"
      expect(link['data-two']).to eq "2"
    end

    it "contains a glyphicon span" do
      expect(link.find('span')['class']).to include 'glyphicon'
      expect(link.find('span')['class']).to include 'glyphicon-ok'
    end

    context "when the task is completed" do
      before { task.update! completed: true }
      specify { expect(link['class']).to include 'completed' }
    end
  end
end
