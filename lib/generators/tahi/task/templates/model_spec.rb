require 'rails_helper'

describe <%= @engine.camelcase %>::<%= @name.camelcase %> do
  describe "A test" do
    it "fails" do
      expect(false)
    end
  end
end
