require 'spec_helper'

describe AuthorsTaskPresenter do
  include Rails.application.routes.url_helpers

  describe "#data_attributes" do
    let(:task) do
      paper = Paper.create! title: "Foo bar", short_title: "Foo", journal: Journal.create!
      task = AuthorsTask.create! title: "Paper Admin",
        completed: true,
        role: 'admin',
        phase: paper.task_manager.phases.first
      allow(task).to receive(:authors).and_return [{one: 1}, {two: 2}]
      task
    end

    subject(:data_attributes) { AuthorsTaskPresenter.new(task).data_attributes }

    it_behaves_like "all tasks, which have common attributes" do
      before do
        user = mock_model User, full_name: 'Mock User'
        allow(User).to receive(:admins).and_return [user]
      end

      let(:card_name) { 'authors' }
      let(:assignees) { '[]' }
    end

    it "includes custom figure data" do
      expect(data_attributes).to include(
        'authors' => '[{"one":1},{"two":2}]',
      )
    end
  end
end
