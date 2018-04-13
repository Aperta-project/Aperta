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

# Non-ActiveRecord model for easily collecting and serializing the data
# for a Funder.
class Funder
  include ActiveModel::SerializerSupport

  def self.from_task(task)
    answers = task.answers.includes(:card_content, :repetition)
    task.repetitions.map do |repetition|
      new(answers, repetition)
    end
  end

  def initialize(answers, repetition)
    @answers = answers
    @repetition = repetition
  end

  def name
    answer_for("funder--name")
  end

  def grant_number
    answer_for("funder--grant_number")
  end

  def website
    answer_for("funder--website")
  end

  def additional_comments
    answer_for("funder--additional_comments")
  end

  def influence
    answer_for("funder--had_influence")
  end

  def influence_description
    answer_for("funder--had_influence--role_description")
  end

  def funding_statement
    return additional_comments if only_has_additional_comments?

    s = "#{name} #{website} (grant number #{grant_number})."
    s << " #{additional_comments}." if additional_comments.present?
    s << if influence
           " #{influence_description}."
         else
           " The funder had no role in study design, data collection and analysis, decision to publish, or preparation of the manuscript."
         end
    s
  end

  private

  def only_has_additional_comments?
    additional_comments.present? && name.blank? && grant_number.blank? && website.blank?
  end

  def answer_for(ident)
    @answers.detect { |answer|
      answer.card_content.ident == ident && answer.repetition == @repetition
    }.try!(:value)
  end
end
