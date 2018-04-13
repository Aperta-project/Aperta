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

describe TahiStandardTasks::LetterTemplate do
  subject(:template) { described_class.new(salutation: salutation, body: body) }
  let(:salutation) { "Dear SoAndSo," }
  let(:body) { "You've won a million dollars!" }

  it "has a salutation" do
    expect(template.salutation).to eq(salutation)
  end

  it "has a body" do
    expect(template.body).to eq(body)
  end

  it "can be returned as_json" do
    expect(template.as_json).to eq(salutation: salutation, body: body)
  end

  it "can be converted to_json" do
    expect(template.to_json).to eq({ salutation: salutation, body: body }.to_json)
  end
end
