require 'spec_helper'
describe "dashboards/index" do
  let(:all_submitted_papers) { [] }

  before do
    view.stub(:current_user).and_return mock_model(User)
    assign(:ongoing_papers, [])
    assign(:submitted_papers, [])
    assign(:all_submitted_papers, all_submitted_papers)
  end

  subject { render; Capybara.string(rendered) }

  it { should_not have_text 'submitted paper' }

  context "when there are submitted papers" do
    let(:all_submitted_papers) do
      [mock_model(Paper, short_title: 'submitted paper')]
    end

    it { should have_text 'submitted paper' }
  end
end
