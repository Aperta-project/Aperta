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
  class AuthorSerializer < Typesetter::TaskAnswerSerializer
    attributes :type, :first_name, :last_name, :middle_initial, :email,
               :department, :title, :corresponding, :deceased, :affiliation,
               :secondary_affiliation, :contributions, :government_employee,
               :orcid_profile_url, :orcid_authenticated, :creator

    private

    def creator
      object.creator?
    end

    def include_creator?
      options[:destination].present? && options[:destination] != 'apex'
    end

    def include_orcid_profile_url?
      TahiEnv.orcid_connect_enabled?
    end

    def include_orcid_authenticated?
      TahiEnv.orcid_connect_enabled?
    end

    def orcid_profile_url
      orcid_account.try(:profile_url)
    end

    def orcid_authenticated
      orcid_account.try(:authenticated?)
    end

    def type
      "author"
    end

    def deceased
      object.answer_for('author--deceased').try(:value)
    end

    def corresponding
      object.paper.corresponding_author_emails.include?(object.email)
    end

    def government_employee
      object.answer_for(::Author::GOVERNMENT_EMPLOYEE_QUESTION_IDENT)
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

    def orcid_account
      object.user.try(:orcid_account)
    end
  end
end
