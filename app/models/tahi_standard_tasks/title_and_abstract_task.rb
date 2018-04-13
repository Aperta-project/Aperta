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

module TahiStandardTasks
  # The model class for the Title And Abstract task, which is
  # used by editors to review and edit what iHat extracted from
  # an uploaded docx
  class TitleAndAbstractTask < Task
    include SubmissionTask

    DEFAULT_TITLE = 'Title And Abstract'.freeze
    DEFAULT_ROLE_HINT = 'editor'.freeze

    attr_accessor :paper_title, :paper_abstract

    after_save    :update_paper

    def paper_title
      @paper_title || paper.title
    end

    def paper_abstract
      @paper_abstract || paper.abstract
    end

    def active_model_serializer
      TahiStandardTasks::TitleAndAbstractTaskSerializer
    end

    def self.permitted_attributes
      super << [:paper_title, :paper_abstract]
    end

    def self.setup_new_revision(paper, phase)
      existing_title_and_abstract_task = find_by(paper: paper)
      if existing_title_and_abstract_task
        existing_title_and_abstract_task
          .update(completed: false, phase: phase)
      else
        TaskFactory.create(self, paper: paper, phase: phase)
      end
    end

    private

    def update_paper
      paper.title = paper_title
      paper.abstract = (paper_abstract.blank? ? nil : paper_abstract)
      paper.save!
    end
  end
end
