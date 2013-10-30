shared_examples_for "when the user is not signed in" do
  before { sign_out :user }

  it "redirects to the sign in page" do
    do_request
    expect(response).to redirect_to new_user_session_path
  end
end
