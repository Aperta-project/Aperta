require 'rails_helper'

feature "Submitting a paper", js: true do
  let(:admin) { create :user, :site_admin }
  let!(:paper) { FactoryGirl.create(:paper_with_phases, creator: admin) }
  let!(:competing_interests_task) do
    FactoryGirl.create(
      :competing_interests_task,
      completed: true,
      phase_id: paper.phases.first.id
    )
  end

  before do
    login_as(admin, scope: :user)
  end

  scenario "snapshots its metadata cards" do
    visit "/"
    click_link paper.title
    paper_page = PaperPage.new

    snapshotted_major_version = paper.major_version
    snapshotted_minor_version = paper.minor_version

    paper_page.submit do |submission_overlay|
      submission_overlay.submit
    end

    snapshot = Snapshot.where(source: competing_interests_task).first
    expect(snapshot).to be
    expect(snapshot.paper).to eq(paper)
    expect(snapshot.major_version).to eq(snapshotted_major_version)
    expect(snapshot.minor_version).to eq(snapshotted_minor_version)
  end
end
