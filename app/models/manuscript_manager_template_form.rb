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
    # since adding a setting is dependent on the task template
    # already existing, we're creating it first but the
    # act_as_list callbacks are tweaking the incoming position
    # values since the association is added later. Running
    # it in the block halts the callbacks and trusts the params
    TaskTemplate.acts_as_list_no_update([TaskTemplate]) do
      ManuscriptManagerTemplate.create!(params)
    end
  end

  def update!(template)
    process_params
    TaskTemplate.acts_as_list_no_update([TaskTemplate]) do
      template.update! params
      template.touch
    end
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
      original_settings = TaskTemplate.find_by(id: param.delete('id')).try(:all_settings) || []
      new_task_template = TaskTemplate.create(param)
      original_settings.each do |setting|
        new_task_template.setting(setting[:name]).update!(value: setting[:value])
      end
      new_task_template
    end
  end
end
