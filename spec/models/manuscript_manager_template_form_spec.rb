require 'rails_helper'

describe "ManuscriptManagerTemplateForm" do

  let(:journal) { FactoryGirl.create(:journal) }
  let(:valid_mmt_form) { ManuscriptManagerTemplateForm.new(valid_params) }
  let(:unvalid_mmt_form) { ManuscriptManagerTemplateForm.new(unvalid_params) }


  it "Creates a ManuscriptManagerTemplate" do
    valid_mmt_form.create_mmt
    last_mmt = ManuscriptManagerTemplate.last
    expect(last_mmt.paper_type).to eql("Research 2222")
    expect(last_mmt.journal).to eql(journal)
  end

  it "Creates phases for the ManuscriptManagerTemplate" do
    valid_mmt_form.create_mmt
    last_mmt = ManuscriptManagerTemplate.last
    expect(last_mmt.phase_templates.size).to eql(3)
    expect(last_mmt.phase_templates[0].name).to eql("Phase 1")
    expect(last_mmt.phase_templates[0].position).to eql(1)
    expect(last_mmt.phase_templates[1].name).to eql("Phase 2")
    expect(last_mmt.phase_templates[1].position).to eql(2)
    expect(last_mmt.phase_templates[2].name).to eql("Phase 3")
    expect(last_mmt.phase_templates[2].position).to eql(3)
  end

  it "Create task_templates for each phase" do
    valid_mmt_form.create_mmt
    last_mmt = ManuscriptManagerTemplate.last
    task_templates = last_mmt.phase_templates.first.task_templates
    expect(task_templates.size).to eql(2)
    expect(task_templates[0].title).to eql("Add Authors")
    expect(task_templates[1].title).to eql("Assign Team")
  end

  it "Ignore unvalid params when creating a ManuscriptManagerTemplate" do
    unvalid_mmt_form.create_mmt
    last_mmt = ManuscriptManagerTemplate.last
    expect(last_mmt.paper_type).to eql("Research 2222")
    expect(last_mmt.journal).to eql(journal)
  end

  def valid_params
    {"paper_type"=>"Research 2222", "journal_id"=>journal.id, "phase_templates"=>[{"name"=>"Phase 1", "position"=>1, "task_templates"=>[{"title"=>"Add Authors", "journal_task_type_id"=>"86"}, {"title"=>"Assign Team", "journal_task_type_id"=>"111"}]}, {"name"=>"Phase 2", "position"=>2}, {"name"=>"Phase 3", "position"=>3}]}
  end

  def unvalid_params
    {"paper_type"=>"Research 2222", "journal_id"=>journal.id, "phase_templates"=> nil}
  end
end
