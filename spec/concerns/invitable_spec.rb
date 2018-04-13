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

describe Invitable do
  let (:invitable_task) { create :invitable_task }
  describe '#invitee_role' do
    context 'when it is not implemented in the task' do
      it 'raises a NotImplementedError' do
        task = create(:ad_hoc_task).extend Invitable
        expect{ task.invitee_role }.to raise_error NotImplementedError
      end
    end

    context 'when it is implemented in the task' do
      it 'does not raise NotImplementedError' do
        allow(invitable_task).to receive(:invitee_role).and_return 'editor'
        expect{ invitable_task.invitee_role }.not_to raise_error
      end
    end
  end
end
