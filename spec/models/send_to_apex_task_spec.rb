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

describe TahiStandardTasks::SendToApexTask do
  let!(:paper) do
    FactoryGirl.create(:paper, :with_tasks, publishing_state: 'accepted')
  end
  let!(:task) do
    FactoryGirl.create(:send_to_apex_task, :with_loaded_card, paper: paper)
  end

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe '#export_deliveries association' do
    let!(:task) do
      FactoryGirl.create(:send_to_apex_task, :with_loaded_card, export_deliveries: [export_delivery])
    end
    let!(:export_delivery) { FactoryGirl.build(:export_delivery, paper: paper, destination: 'apex') }

    it 'destroys export deliveries when the task is destroyed' do
      expect do
        task.destroy
      end.to change { task.export_deliveries.count }.by(-1)

      expect { export_delivery.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
