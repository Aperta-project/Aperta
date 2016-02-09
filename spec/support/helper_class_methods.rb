module TahiHelperClassMethods
  def expect_policy_enforcement
    before(:each) do
      expect(controller).to receive(:authorize_action!).and_call_original
    end
  end

  def authorize_policy(klass, bool)
    before do
      allow_any_instance_of(klass).to receive(:authorized?).and_return(bool)
    end
  end

  def action_policy(klass, action, bool)
    before do
      # Call the original #authorized? in case it was previously stubbed since
      # this action_policy is more specific than authorize_policy
      allow_any_instance_of(klass).to receive(:authorized?).and_call_original
      allow_any_instance_of(klass).to receive("#{action}?".to_sym).and_return(bool)
    end
  end
end
