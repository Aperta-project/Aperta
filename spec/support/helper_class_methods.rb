module TahiHelperClassMethods
  def expect_policy_enforcement
    before(:each) do
      expect(controller).to receive(:authorize_action!).and_call_original
    end
  end
end
