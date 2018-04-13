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

module MailLog
  # ApertaMailContext is used to store a hash of contextual information
  # for a particular email being set.
  class ApertaMailContext
    attr_reader :model_hash

    def initialize(context_hash)
      @context_hash = context_hash
      @model_hash = @context_hash.select do |_key, value|
        value.is_a?(ActiveRecord::Base)
      end
      @task = @model_hash.values.detect { |value| value.is_a?(Task) }
      @paper = @model_hash.values.detect { |value| value.is_a?(Paper) }
      @journal = @model_hash.values.detect { |value| value.is_a?(Journal) }
    end

    def journal
      @journal ||= paper.try(:journal)
    end

    def paper
      @paper ||= task.try(:paper) || fallback_to_first_possible_paper_reference
    end

    def task
      @task
    end

    def to_database_safe_hash
      model_hash.each_with_object({}) do |(key, model), safe_hash|
        safe_hash[key] = [model.model_name.name, model.id]
      end
    end

    private

    # This should be called if you cannot find a paper through other means.
    # It will look for a :paper method on all models in the @model_hash
    # and return the first one with a value.
    def fallback_to_first_possible_paper_reference
      model = @model_hash.values.detect { |model| model.try(:paper) }
      model.try(:paper)
    end
  end
end
