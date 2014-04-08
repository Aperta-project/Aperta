require 'spec_helper'

describe UserSettings do
  describe "after_create" do
    it "initializes with a set of default flows" do
      user_settings = UserSettings.create
      default_flow_titles = ["Up for grabs", "My tasks", "My papers", "Done"]
      expect(user_settings.flows.map(&:title)).to match_array default_flow_titles
    end
  end
end
