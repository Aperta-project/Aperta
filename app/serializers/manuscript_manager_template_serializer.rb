class ManuscriptManagerTemplateSerializer < ActiveModel::Serializer
  attributes :id, :paper_type, :template
  has_one :journal, embed: :ids

  def template
    phases = object.template["phases"] || []
    object.template.merge({
      "phases" => phases.map do |phase|
        phase["task_types"] = [] unless phase["task_types"]
        phase
      end
    })
  end
end
