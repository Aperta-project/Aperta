shared_examples_for "when the user is not signed in" do
  before { sign_out :user }

  it "redirects to the sign in page" do
    do_request
    expect(response).to redirect_to new_user_session_path
  end
end

shared_examples_for "an unauthenticated json request" do
  before { sign_out :user }

  it "returns 401" do
    do_request
    expect(response.status).to eq(401)
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
  let(:returned_params) { {} }

  it "allows specified params" do
    params_format ||= 'html'
    fake_params = double(:params)
    allow(fake_params).to receive(:[]) do |key|
      fake_scoped_model_id key
    end
    model_params = double(:model_params)
    allow(controller).to receive(:params).and_return(fake_params)
    expect(fake_params).to receive(:require).at_least(:once).with(model_identifier).and_return(model_params)
    expect(model_params).to receive(:permit).at_least(:once).with(*expected_params).and_return(returned_params)
    controller.stub(:render)
    do_request
  end

  def fake_scoped_model_id key
    if key.to_s == 'id'
      params_id
    elsif key.to_s.ends_with? '_id'
      scoped_model_name = key.to_s.scan(/(.*)_id/).first.first
      scoped_model_method = "params_#{scoped_model_name}_id"
      send(scoped_model_method) if respond_to? scoped_model_method
    elsif !key.to_s.ends_with?('id')
      {}
    end
  end
end
