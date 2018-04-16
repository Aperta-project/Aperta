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

describe PhaseTemplatesController do
  let(:user) { create :user, :site_admin }
  before { sign_in user }

  let(:mmt) { FactoryGirl.create(:manuscript_manager_template) }
  let(:phase_template) { FactoryGirl.create(:phase_template, manuscript_manager_template: mmt) }

  it "creates a record" do
    post :create, format: :json, phase_template: { name: "A Phase", manuscript_manager_template_id: mmt.id, position: 0 }
    expect(response.status).to eq(201)
    expect(PhaseTemplate.find(res_body.with_indifferent_access[:phase_template][:id])).to_not be_nil
  end

  it "updates a record" do
    put :update, format: :json, id: phase_template.id, phase_template: { name: "Phase Transition", manuscript_manager_template_id: mmt.id, position: 0 }
    expect(response.status).to eq(204)
  end

  it "deletes a record" do
    delete :destroy, format: :json, id: phase_template.id
    expect(response.status).to eq(204)
  end
end
