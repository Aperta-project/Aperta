shared_examples_for "when the user is not signed in" do
  before { sign_out :user }

  it "redirects to the sign in page" do
    do_request
    expect(response).to redirect_to new_user_session_path
  end
end

shared_examples_for "a controller enforcing strong parameters" do
  let(:params_id) { nil }

  it "allows specified params" do
    fake_params = double(:params, :[] => params_id)
    model_params = double(:model_params)

    controller.stub(:params).and_return fake_params
    expect(fake_params).to receive(:require).with(model_identifier).and_return(model_params)
    expect(model_params).to receive(:permit).with *allowed_params

    do_request
  end
end
