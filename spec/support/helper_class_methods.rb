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
end
