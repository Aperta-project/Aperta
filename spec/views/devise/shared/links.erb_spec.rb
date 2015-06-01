require 'rails_helper'

describe "sign in / up page links: " do

  describe "when Orcid is enabled" do

    before do
      Rails.configuration.orcid_enabled = true
      render partial: 'devise/shared/links'
    end

    it "shows Orcid button" do
      expect(rendered).to have_text 'Sign in with ORCID'
    end
  end

  describe "when Orcid is not enabled" do

    before do
      Rails.configuration.orcid_enabled = false
      render partial: 'devise/shared/links'
    end

    it "doesn't show Orcid button" do
      expect(rendered).to_not have_text 'Sign in with ORCID'
    end
  end

end
