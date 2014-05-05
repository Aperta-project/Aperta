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
    let(:paper) do
      FactoryGirl.create(:paper)
    end

    let(:task) do
      Task.create! title: 'Foo task',
        role: 'some role',
        phase: paper.phases.first
    end

    subject(:link) do
      Capybara.string(helper.card task).find 'a'
    end

    specify { expect(link.text.strip).to eq task.title }
    specify { expect(link['href']).to eq task_path(task) }
    specify { expect(link['class']).to include 'card' }
    specify { expect(link['class']).to_not include 'completed' }

    it "includes data necessary to render a card" do
      expect(link['data-task-path']).to eq task_path(task)
      expect(link['data-card-name']).to eq 'task'
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
