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

describe JournalServices::CreateDefaultManuscriptManagerTemplates do
  let(:service) { JournalServices::CreateDefaultManuscriptManagerTemplates }
  let(:journal) { FactoryGirl.create(:journal) }

  before do
    # make sure journal task types are created - required before MMT
    CardTaskType.seed_defaults
    JournalServices::CreateDefaultTaskTypes.call(journal)
  end

  it "creates default manager templates" do
    expect do
      service.call(journal)
    end.to change { journal.manuscript_manager_templates.count } .by(1)
  end

  describe ".create_phase_template" do
    let(:mmt) { FactoryGirl.create(:manuscript_manager_template, journal: journal) }

    it "creates a new phase template with a journal task type" do
      phase_template = service.create_phase_template(
        name: "A New Phase Name",
        journal: journal,
        mmt: mmt,
        phase_content: TahiStandardTasks::SupportingInformationTask
      )

      expect(phase_template.task_templates.length).to eq(1)
      expect(phase_template.task_templates.first.journal_task_type).to be_kind_of(JournalTaskType)
    end
  end
end
