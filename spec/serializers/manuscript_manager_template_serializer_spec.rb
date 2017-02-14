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
