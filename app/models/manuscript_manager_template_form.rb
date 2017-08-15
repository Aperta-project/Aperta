class ManuscriptManagerTemplateForm
  include ActiveModel::Model

  attr_accessor :params

  validates :paper_type, presence: true
  validates :journal_id, presence: true

  def initialize(params)
    @params = params
  end

  def create!
    process_params
    ManuscriptManagerTemplate.create!(params)
  end

  def update!(template)
    process_params
    template.update! params
  end

  private

  def process_params
    phase_templates = set_phase_templates(params.delete("phase_templates"))
    params["phase_templates"] = phase_templates if phase_templates
  end

  def set_phase_templates(phase_template_params)
    return if phase_template_params.nil?
    phase_template_params.map do |param|
      task_templates = set_task_templates(param.delete("task_templates"))
      param["task_templates"] = task_templates if task_templates
      PhaseTemplate.new param
    end
  end

  def set_task_templates(task_template_params)
    return if task_template_params.nil?
    task_template_params.map do |param|
      original_settings = TaskTemplate.find_by_id(param.delete('id')).try(:all_settings) || []
      new_task_template = TaskTemplate.create(param)
      original_settings.each do |setting|
        new_task_template.setting(setting[:name]).update!(value: setting[:value])
      end
      new_task_template
    end
  end
end
