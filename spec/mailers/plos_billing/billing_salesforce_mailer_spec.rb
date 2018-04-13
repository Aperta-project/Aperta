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

require 'rails_helper'

describe PlosBilling::BillingSalesforceMailer do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:site_admin_role) { FactoryGirl.create(:role, :site_admin) }
  let(:the_system) { System.create! }
  let!(:admin1) { FactoryGirl.create(:user) }
  let!(:admin2) { FactoryGirl.create(:user) }

  describe "#notify_site_admins_of_syncing_error" do
    let(:message) { "Error! Bad things happened. Contact a Developer" }
    let(:email) do
      described_class.notify_site_admins_of_syncing_error(paper.id, message)
    end

    before do
      admin1.assign_to! assigned_to: the_system, role: site_admin_role
      admin2.assign_to! assigned_to: the_system, role: site_admin_role
    end

    it "displays the error message for developers" do
      expect(email.body).to include(message)
    end

    it "contains the paper doi" do
      expect(email.body).to include(paper.doi)
    end

    it "is sent to the users assigned as site admins" do
      expect(email.to).to contain_exactly(admin1.email, admin2.email)
    end
  end
end
