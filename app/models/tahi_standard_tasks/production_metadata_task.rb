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
  class ProductionMetadataTask < Task
    DEFAULT_TITLE = 'Production Metadata'.freeze
    DEFAULT_ROLE_HINT = 'admin'.freeze

    with_options(if: :newly_complete?) do
      validates :volume_number, :issue_number,
        numericality: { only_integer: true, message: 'must be a whole number' }

      validates :publication_date,
        allow_blank: true,
        format: { with: /\A\d{2}\/\d{2}\/\d{4}\Z/,
                  message: 'must be a date in mm/dd/yyy format' }
    end

    def active_model_serializer
      ProductionMetadataTaskSerializer
    end

    def publication_date
      answer_for("production_metadata--publication_date").try(:value)
    end

    def provenance
      answer_for("production_metadata--provenance").try(:value)
    end

    def special_handling_instructions
      answer_for("production_metadata--special_handling_instructions")
        .try(:value)
    end

    def volume_number
      answer_for("production_metadata--volume_number").try(:value)
    end

    def issue_number
      answer_for("production_metadata--issue_number").try(:value)
    end
  end
end
