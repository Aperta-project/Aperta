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

class PaperFactory
  attr_reader :paper, :creator

  def self.create(paper_params, creator)
    # number_reviewer_reports is applied for all new papers as of APERTA-7810.
    # it's not exposed to the client.
    paper_params[:number_reviewer_reports] = true
    paper = Paper.new(paper_params)

    pf = new(paper, creator)
    pf.create
    pf.paper
  end

  def initialize(paper, creator)
    @paper = paper
    @creator = creator
  end

  def create
    Paper.transaction do
      return unless paper.valid?
      if template
        paper.uses_research_article_reviewer_report =
          template.uses_research_article_reviewer_report
        paper.save!
        # TODO: This requires roles & permissions tables to exist. It should
        # be possible to create a paper for testing without them.
        add_creator_assignment!
        add_phases_and_tasks
        add_creator_as_author!
      else
        paper.errors.add(:paper_type, 'is not valid')
      end
    end
  end

  def add_phases_and_tasks
    template.phase_templates.each do |phase_template|
      phase = paper.phases.create!(name: phase_template['name'])
      phase_template.task_templates.each do |task_template|
        if task_template.card
          create_task_from_card(task_template, phase)
        else
          create_task_from_template(task_template, phase)
        end
      end
    end
  end

  private

  def template
    @template ||= paper.journal.manuscript_manager_templates
                  .find_by(paper_type: paper.paper_type)
  end

  def create_task_from_template(task_template, phase)
    task_klass = Task.safe_constantize(task_template.journal_task_type.kind)
    task = TaskFactory.create(
      task_klass,
      phase: phase,
      paper: phase.paper,
      creator: creator,
      title: task_template.title,
      body: task_template.template,
      notify: false,
      task_template: task_template
    )
    task
  end

  def create_task_from_card(task_template, phase)
    task = TaskFactory.create(
      Task.safe_constantize(task_template.card.card_task_type.task_class),
      phase: phase,
      paper: phase.paper,
      creator: creator,
      card_version: task_template.card.latest_published_card_version,
      title: task_template.title,
      notify: false,
      task_template: task_template
    )
    task
  end

  def add_creator_assignment!
    creator.assignments.create!(
      assigned_to: paper,
      role: paper.journal.creator_role
    )
  end

  def add_creator_as_author!
    DefaultAuthorCreator.new(paper, creator).create!
  end
end
