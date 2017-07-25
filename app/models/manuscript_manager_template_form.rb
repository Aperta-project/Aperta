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
      settings = set_settings(param.delete("settings"))
      param["settings"] = settings if settings.present?
      TaskTemplate.new param
    end
  end

  def set_settings(setting_params)
    return if setting_params.nil?
    setting_params.map do |param|
      # since old task template is getting deleted, we have to create
      # a new setting without any references to the deleted owner.
      setting = Setting.new
      setting.name = param['name']
      setting.string_value = param['string_value']
      setting.value_type = param['value_type']
      setting.integer_value = param['integer_value']
      setting.boolean_value = param['boolean_value']
      setting.setting_template_id = param['setting_template_id']
      setting.owner_type = param['owner_type']
      setting
    end
  end
end
