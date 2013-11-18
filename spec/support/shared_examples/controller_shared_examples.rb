shared_examples_for "when the user is not signed in" do
  before { sign_out :user }

  it "redirects to the sign in page" do
    do_request
    expect(response).to redirect_to new_user_session_path
  end
end

shared_examples_for "when the user is not an admin" do
  before do
    user.update_attribute :admin, false
    do_request
  end

  it "renders a flash alert" do
    expect(flash[:alert]).to eq "Permission denied"
  end

  it "redirects to the root path" do
    expect(response).to redirect_to root_path
  end
end

shared_examples_for "a controller enforcing strong parameters" do
  let(:params_id) { nil }

  it "allows specified params" do
    fake_params = double(:params)
    allow(fake_params).to receive(:[]) { |key| key.to_s == 'id' ? params_id : {} }
    model_params = double(:model_params)

    allow(controller).to receive(:params).and_return(fake_params)
    expect(fake_params).to receive(:require).with(model_identifier).and_return(model_params)
    expect(model_params).to receive(:permit).with *expected_params

    do_request
  end
end
