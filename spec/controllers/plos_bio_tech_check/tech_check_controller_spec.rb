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

module PlosBioTechCheck
  describe TechCheckController do
    let(:user) { FactoryGirl.build_stubbed :user }
    let(:task) { FactoryGirl.build_stubbed :final_tech_check_task }
    let(:notify_service) do
      instance_double(NotifyAuthorOfChangesNeededService, notify!: nil)
    end

    describe '#send_email' do
      subject(:do_request) do
        post :send_email, id: task.id, format: :json
      end

      before do
        allow(Task).to receive(:find)
          .with(task.to_param)
          .and_return task
      end

      it_behaves_like 'an unauthenticated json request'

      context 'when the user has access' do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return true
          allow(NotifyAuthorOfChangesNeededService).to receive(:new)
            .and_return notify_service
        end

        it 'tells notify service to notify the author' do
          allow(NotifyAuthorOfChangesNeededService).to receive(:new)
            .with(task, submitted_by: user)
            .and_return notify_service
          expect(notify_service).to receive(:notify!)
          do_request
        end

        it { is_expected.to responds_with(200) }
      end

      context 'when the user does not have access' do
        before do
          stub_sign_in user
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return false
        end

        it { is_expected.to responds_with(403) }
      end
    end
  end
end
