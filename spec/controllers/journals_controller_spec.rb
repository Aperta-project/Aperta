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

describe JournalsController do

  let(:user) { create :user }
  let(:journal) { FactoryGirl.create(:journal) }

  let! (:setting_template) do
    FactoryGirl.create(:setting_template,
     key: "Journal",
     setting_name: "coauthor_confirmation_enabled",
     value_type: 'boolean',
     boolean_value: true)
  end

  before { sign_in user }

  context "#index" do
    it "will allow access" do
      get :index, format: :json
      expect(response.status).to eq(200)
    end
  end

  context "#show" do
    it "will allow access" do
      get :show, id: journal.id, format: :json
      expect(response.status).to eq(200)
    end
  end
end
