class ManuscriptManagerTemplateForm
  include ActiveModel::Model

  attr_accessor :mmt_params

  validates :paper_type, presence: true
  validates :journal_id, presence: true

  def initialize(mmt_params)
    @mmt_params = mmt_params
  end

  def create_mmt
    phase_templates = set_phase_templates(mmt_params.delete("phase_templates"))
    mmt_params["phase_templates"] = phase_templates if phase_templates
    ManuscriptManagerTemplate.create!(mmt_params)
  end

  private

  def set_phase_templates(params)
    return if params.nil?
    params.map do |param|
      task_templates = set_task_templates(param.delete("task_templates"))
      param["task_templates"] = task_templates if task_templates
      PhaseTemplate.new param
    end
  end

  def set_task_templates(params)
    return if params.nil?
    params.map{|param| TaskTemplate.new param}
  end

end