# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
  it "returns 403" do
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
