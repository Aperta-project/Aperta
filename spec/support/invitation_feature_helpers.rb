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

require 'support/pages/sign_in_page'
require 'support/pages/sign_up_page'
require 'support/sidekiq_helper_methods'

module InvitationFeatureHelpers
  include SidekiqHelperMethods

  def invite_new_reviewer_for_paper(email, paper)
    invite_new_user_for_paper(email, paper)
  end

  def ensure_email_got_sent_to(email)
    expect do
      process_sidekiq_jobs
    end.to change(ActionMailer::Base.deliveries, :count)
    expect(find_email(email)).to_not be_nil
  end

  def sign_up_as(email)
    SignInPage.visit
    click_on "Sign up"
    SignUpPage.new.sign_up_as(email: email)
  end

  def invite_new_editor_for_paper(email, paper)
    invite_new_user_for_paper(email, paper)
  end

  def invite_new_user_for_paper(email, paper)
    overlay = Page.view_task_overlay(paper, task)
    overlay.invite_new_user email
    expect(overlay).to have_invitees email
    visit "/"
  end
end
