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

require "rails_helper"

describe ManuscriptManagerTemplateSerializer, serializer_test: true do
  let(:mmt) do
    FactoryGirl.build_stubbed \
      :manuscript_manager_template,
      journal: journal,
      phase_templates: [phase_template]
  end
  let(:journal) { FactoryGirl.create(:journal) }
  let(:phase_template) { FactoryGirl.build_stubbed(:phase_template) }
  let(:object_for_serializer) { mmt }
  let!(:paper) { FactoryGirl.create(:paper, journal: journal, paper_type: mmt.paper_type) }

  let(:mmt_content){ deserialized_content.fetch(:manuscript_manager_template) }

  it 'serializes successfully' do
    expect(deserialized_content).to match \
      hash_including(:manuscript_manager_template)

    expect(mmt_content).to match hash_including(
      id: mmt.id,
      paper_type: mmt.paper_type,
      uses_research_article_reviewer_report:
        mmt.uses_research_article_reviewer_report,
      journal_id: journal.id,
      phase_template_ids: [phase_template.id],
      active_paper_ids: [paper.id]
    )
  end
end
