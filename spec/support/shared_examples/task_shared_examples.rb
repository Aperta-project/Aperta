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

shared_examples '<Task class>.restore_defaults does not update title' do
  let!(:task_class) do
    described_class.name.demodulize.underscore.to_sym
  end
  let!(:task_1) do
    FactoryGirl.create(task_class, title: 'Foo bar')
  end
  let!(:task_2) do
    FactoryGirl.create(task_class, title: 'Baz foo')
  end

  it 'does not restore the title of any of its instances' do
    expect do
      described_class.restore_defaults
    end.to_not change { [task_1.reload.title, task_2.reload.title] }
  end
end

shared_examples '<Task class>.restore_defaults update title to the default' do
  let!(:task_class) do
    described_class.name.demodulize.underscore.to_sym
  end
  let!(:task_1) do
    FactoryGirl.create(task_class, title: 'Foo bar')
  end
  let!(:task_2) do
    FactoryGirl.create(task_class, title: 'Baz foo')
  end

  it 'does not restore the title of any of its instances' do
    expect do
      described_class.restore_defaults
    end.to change { [task_1.reload.title, task_2.reload.title] }.to(
      [described_class::DEFAULT_TITLE, described_class::DEFAULT_TITLE]
    )
  end
end
