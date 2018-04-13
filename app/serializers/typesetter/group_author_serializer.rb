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

module Typesetter
  # Serializes author for the typesetter.
  # Expects an author as its object to serialize.
  class GroupAuthorSerializer < Typesetter::TaskAnswerSerializer
    attributes :type, :name,
               :contact_first_name, :contact_last_name, :contact_middle_name,
               :contact_email, :contributions, :government_employee

    private

    def type
      "group_author"
    end

    def government_employee
      object.answer_for(::GroupAuthor::GOVERNMENT_EMPLOYEE_QUESTION_IDENT)
        .try(:value)
    end

    def contributions
      object.contributions.map do |contribution|
        if contribution.value_type == 'boolean'
          contribution.card_content.text if contribution.value
        elsif contribution.value_type == 'text'
          contribution.value
        else
          raise TypeSetter::MetadataError,
               "Unknown contribution type #{contribution.value_type}"
        end
      end.compact
    end
  end
end
