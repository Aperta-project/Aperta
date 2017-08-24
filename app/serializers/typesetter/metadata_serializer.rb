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

    attribute :aarx_doi

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
      task('TahiStandardTasks::FinancialDisclosureTask')
    end

    def data_availability
      custom_task('Data Availability')
    end

    def early_article_posting
      task('TahiStandardTasks::EarlyPostingTask').try(:answer_for, 'early-posting--consent').try(:value) || false
    end

    def custom_card_fields
      custom_tasks_questions_answers
    end
  end
end
