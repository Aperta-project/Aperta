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

class ManuscriptManagerTemplatesController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    journal_ids = current_user.filter_authorized(
      :administer,
      Journal,
      participations_only: false
    ).objects.map(&:id)

    # if a specific journal id is sent with the request, use it to
    # filter down to manuscript manager templates for that journal
    if params['journal_id']
      journal_ids = journal_ids.select { |j| j == params['journal_id'].to_i }
    end

    respond_with ManuscriptManagerTemplate.where(journal_id: journal_ids)
    .includes(:journal,
      phase_templates: { task_templates: [
        :journal_task_type,
        card: { card_versions: { card_contents: [:card_content_validations, :children] } }
      ] })
  end

  def show
    requires_user_can_view(manuscript_manager_template)
    respond_with manuscript_manager_template
  end

  def update
    requires_user_can(:administer, manuscript_manager_template.journal)
    template_form = ManuscriptManagerTemplateForm.new(new_template_params)
    template_form.update! manuscript_manager_template
    render json: manuscript_manager_template
  end

  def create
    requires_user_can(:administer, manuscript_manager_template.journal)
    template_form = ManuscriptManagerTemplateForm.new(new_template_params)
    respond_with template_form.create!
  end

  def destroy
    requires_user_can(:administer, manuscript_manager_template.journal)
    journal = manuscript_manager_template.journal
    if journal.manuscript_manager_templates.count > 1
      manuscript_manager_template.destroy
    else
      manuscript_manager_template.errors.add(:base, "Cannot destroy last template")
    end

    respond_with manuscript_manager_template
  end

  private

  def template_params
    params.require(:manuscript_manager_template).permit(
      :paper_type,
      :journal_id,
      :uses_research_article_reviewer_report,
      :is_preprint_eligible
    )
  end

  def new_template_params
    params.require(:manuscript_manager_template).permit(
      :paper_type,
      :journal_id,
      :uses_research_article_reviewer_report,
      :is_preprint_eligible,
      phase_templates: [
        :name, :position, task_templates: [
          :title, :journal_task_type_id, :position, :card_id, :id
        ]
      ]
    ).tap do |whitelisted|
      whitelisted[:phase_templates].try(:each_index) do |i|
        pt = whitelisted[:phase_templates][i]
        pt[:task_templates].try(:each_index) do |j|
          template_value = params[:manuscript_manager_template][:phase_templates][i][:task_templates][j][:template]
          whitelisted[:phase_templates][i][:task_templates][j][:template] = template_value || []
        end
      end
    end
  end

  def manuscript_manager_template
    @mmt ||= if params[:id]
      ManuscriptManagerTemplate.find(params[:id])
    else
      ManuscriptManagerTemplate.new(template_params)
    end
  end

end
