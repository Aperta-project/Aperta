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

describe Invitation::Updated::EventStream::NotifyInvitee do
  include EventStreamMatchers

  context "with an invitee" do
    let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
    let!(:invitation) { FactoryGirl.build(:invitation) }

    it "serializes invitation down the user channel on update" do
      expect(pusher_channel).to receive_push(serialize: invitation, down: 'user', on: 'updated')
      described_class.call("tahi:invitation:updated", { action: "updated", record: invitation })
    end
  end

  context "without an invitee (invitee is user without an tahi account)" do
    let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
    let!(:invitation) { FactoryGirl.build(:invitation, invitee: nil) }

    it "does not serialize invitation" do
      expect(pusher_channel).to_not receive_push(down: 'user', on: 'update')
      described_class.call("tahi:invitation:updated", { action: "updated", record: invitation })
    end
  end
end
