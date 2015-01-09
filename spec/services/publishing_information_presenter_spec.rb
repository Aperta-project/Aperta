require 'rails_helper'

describe PublishingInformationPresenter do
  let(:paper) { FactoryGirl.create :paper, title: "Studies on the aftermath of revolution", published_at: 2.days.ago }
  let(:downloader) { FactoryGirl.create :user }
  let(:publishing_information_presenter) { PublishingInformationPresenter.new(paper, downloader) }

  it "#html returns complete publishing information" do
    %i(title journal_name generated_at).each do |method|
      expect(publishing_information_presenter).to receive(method)
    end
    publishing_information_presenter.html
  end

  it "#title returns the title of the manuscript in an h1 tag" do
    expect(publishing_information_presenter.title).to eq "<h1 id='paper-display-title'>#{paper.display_title}</h1>"
  end

  it "#journal_name returns the journal name in a p tag" do
    expect(publishing_information_presenter.journal_name).to eq "<p id='journal-name'><em>#{paper.journal.name}</em></p>"
  end

  it "#generated_at returns the date and time the PDF was created in US long date format" do
    expect(publishing_information_presenter.generated_at).to eq "<p id='generated-at'><em>#{Date.today.to_s :long}</em></p>"
  end

  it "#downloader_name returns the name of the user the PDF was generated for in a p tag at the end" do
    expect(publishing_information_presenter.downloader_name).to eq "Generated for #{downloader.full_name}"
  end
end
