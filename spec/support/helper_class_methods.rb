module TahiHelperClassMethods
  def expect_policy_enforcement
    before(:each) do
      controller.should_receive(:authorize_action!).and_call_original
    end
  end
end
