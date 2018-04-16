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

describe Comment do
  subject(:comment) { FactoryGirl.build(:comment) }

  context 'validation' do
    it 'is valid' do
      expect(comment.valid?).to be(true)
    end

    it 'requires a body' do
      comment.body = nil
      expect(comment.valid?).to be(false)
    end

    it 'requires a task' do
      comment.task = nil
      expect(comment.valid?).to be(false)
    end
  end

  describe '#created_by?' do
    let(:commenter) { FactoryGirl.build_stubbed(:user) }
    let(:other_commenter) { FactoryGirl.build_stubbed(:user) }

    it 'returns true when the given user is the commenter' do
      comment.commenter = commenter
      expect(comment.created_by?(commenter)).to be(true)
    end

    it 'returns false otherwise' do
      expect(comment.created_by?(other_commenter)).to be(false)
    end
  end
end
