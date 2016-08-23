shared_examples_for "when the user is not signed in" do
  before { sign_out :user }

  it "redirects to the sign in page" do
    do_request
    expect(response).to redirect_to new_user_session_path
  end
end

shared_examples_for "an unauthenticated json request" do
  it "returns 401" do
    do_request
    expect(response.status).to eq(401)
  end
end

shared_examples_for "a forbidden json request" do
  it "returns 401" do
    do_request
    expect(response.status).to eq(403)
  end
end

shared_examples_for "a controller rendering an invalid model" do
  it "returns 422 and the model's errors" do
    do_request
    expect(response.status).to eq(422)
    expect(res_body).to have_key('errors')
  end
end

shared_examples_for "when the user is not an admin" do
  before do
    user.update_attribute :site_admin, false
    do_request
  end

  it "renders a flash alert" do
    expect(flash[:alert]).to eq "Permission denied"
  end

  it "redirects to the root path" do
    expect(response).to redirect_to root_path
  end
end
