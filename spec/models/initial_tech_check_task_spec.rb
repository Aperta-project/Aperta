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

describe PlosBioTechCheck::InitialTechCheckTask do
  subject(:task) { FactoryGirl.create :initial_tech_check_task, paper: paper }
  let(:paper) do
    FactoryGirl.create(
      :paper,
      :submitted,
      :with_creator,
      journal: journal
    )
  end
  let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe '#round' do
    it 'initializes with the round 1' do
      expect(task.round).to eq 1
    end
  end

  describe '#increment_round' do
    context 'when the round key is correctly initialized in #body' do
      it 'increments the round by 1' do
        expect(task.body).to eq('round' => 1)
        task.increment_round!
        expect(task.round).to eq 2
      end
    end

    context 'when the round key is incorrectly initialized in #body' do
      it 'increments the round by 1' do
        task.update! body: {}
        task.increment_round!
        expect(task.round).to eq 2

        task.update! body: { hello: 'hi' }
        task.increment_round!
        expect(task.round).to eq 2
      end
    end
  end
end
