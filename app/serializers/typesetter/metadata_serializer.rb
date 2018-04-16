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
  # Serializes a paper's metadata for the typesetter
  # Expects a paper as its object to serialize.
  class MetadataSerializer < Typesetter::TaskAnswerSerializer
    attributes :aarx_doi, :short_title, :doi, :manuscript_id, :paper_type, :journal_title,
               :publication_date, :provenance, :special_handling_instructions,
               :early_article_posting, :custom_card_fields, :paper_title
    attribute :first_submitted_at, key: :received_date
    attribute :accepted_at, key: :accepted_date
    attribute :abstract, key: :paper_abstract

    has_one :competing_interests,
            serializer: Typesetter::CompetingInterestsSerializer
    has_one :financial_disclosure,
            serializer: Typesetter::FinancialDisclosureSerializer
    has_one :data_availability,
            serializer: Typesetter::DataAvailabilitySerializer

    has_many :author_list_items,
             serializer: Typesetter::AuthorListItemSerializer,
             key: :authors
    has_many :academic_editors,
             serializer: Typesetter::EditorSerializer
    has_many :supporting_information_files,
             serializer: Typesetter::SupportingInformationFileSerializer
    has_many :related_articles,
             serializer: Typesetter::RelatedArticleSerializer

    def include_aarx_doi?
      options[:destination] == 'preprint'
    end

    def include_custom_card_fields?
      options[:destination] != 'apex'
    end

    def journal_title
      object.journal.name
    end

    def paper_title
      title_clean(object.title)
    end

    def short_title
      title_clean(object.short_title)
    end

    def publication_date
      production_metadata.try(:publication_date).try(:to_date)
    end

    def related_articles
      object.related_articles.where(send_link_to_apex: true)
    end

    def provenance
      production_metadata.try(:provenance) || ''
    end

    def special_handling_instructions
      production_metadata.try(:special_handling_instructions) || ''
    end

    def supporting_information_files
      object.supporting_information_files.publishable
    end

    def production_metadata
      task('TahiStandardTasks::ProductionMetadataTask')
    end

    def competing_interests
      custom_task('Competing Interests')
    end

    def financial_disclosure
      custom_task('Financial Disclosure')
    end

    def data_availability
      custom_task('Data Availability')
    end

    def early_article_posting
      custom_task('Early Version').try(:answer_for, 'early-posting--consent').try(:value) || false
    end

    def custom_card_fields
      custom_tasks_questions_answers
    end
  end
end
