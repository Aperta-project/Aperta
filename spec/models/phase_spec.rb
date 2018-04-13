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

describe Phase do
  it "defines a DEFAULT_PHASE_NAME" do
    expect(Phase.const_defined? :DEFAULT_PHASE_NAMES).to be_truthy
  end

  describe ".default_phases" do
    before do
      stub_const "Phase::DEFAULT_PHASE_NAMES", %w(Todo Doing Done)
    end

    subject(:phases) { Phase.default_phases }

    it "returns an array of phase instances for each phase name" do
      expect(phases.size).to eq(3)
      expect(phases[0].name).to eq "Todo"
      expect(phases[1].name).to eq "Doing"
      expect(phases[2].name).to eq "Done"
    end

    it "does not persist any of the phases" do
      expect(phases.all? &:new_record?).to be true
    end
  end

end
