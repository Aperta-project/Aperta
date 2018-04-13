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

describe JournalServices::UpdateDefaultTasks do
  it 'Updates task title to default' do
    task = FactoryGirl.create(:revise_task, title: 'Old Title')
    JournalServices::UpdateDefaultTasks.call
    expect(task.reload.title).to eq(task.class::DEFAULT_TITLE)
  end

  it 'Does not update Ad-hoc tasks title' do
    adhoc_task = FactoryGirl.create(:ad_hoc_task, title: 'Custom Ad-hoc Task')
    JournalServices::UpdateDefaultTasks.call
    expect(adhoc_task.reload.title).to eq('Custom Ad-hoc Task')
  end
end
