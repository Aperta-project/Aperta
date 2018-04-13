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

require 'support/pages/dashboard_page'

class SignUpPage < Page
  path :new_user_registration

  def sign_up_as options
    user = FactoryGirl.build(:user)
    fill_in "Username", with: options.fetch(:username){ user.username }
    fill_in "First name", with: options.fetch(:first_name){ user.first_name }
    fill_in "Last name", with: options.fetch(:last_name){ user.last_name }
    fill_in "Email", with: options.fetch(:email){ user.email }
    fill_in "Password", with: options.fetch(:password){ "password" }
    fill_in "Password confirmation", with: options.fetch(:password){ "password" }
    click_on "Sign up"

    DashboardPage.new
  end
end
