module Typesetter
  # Serializes a paper's metadata for the typesetter
  # Expects a paper as its object to serialize.
  class MetadataSerializer < Typesetter::TaskAnswerSerializer
    include ActiveModel::Validations
    validates :verdict_was_accepted?, presence: true

    attributes :short_title, :doi, :manuscript_id, :paper_type, :journal_title,
               :publication_date, :provenance, :special_handling_instructions
    attribute :first_submitted_at, key: :received_date
    attribute :accepted_at, key: :accepted_date
    attribute :title, key: :paper_title

    has_one :competing_interests,
            serializer: Typesetter::CompetingInterestsSerializer
    has_one :financial_disclosure,
            serializer: Typesetter::FinancialDisclosureSerializer
    has_one :data_availability,
            serializer: Typesetter::DataAvailabilitySerializer
    has_many :author_list_items,
             serializer: Typesetter::AuthorListItemSerializer,
             key: :authors
    has_many :academic_editors, serializer: Typesetter::EditorSerializer
    has_many :supporting_information_files,
             serializer: Typesetter::SupportingInformationFileSerializer

    def verdict_was_accepted?
      object.decisions.latest.verdict == 'accept'
    end

    def journal_title
      object.journal.name
    end

    def publication_date
      production_metadata.try(:publication_date).try(:to_date)
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
      task('TahiStandardTasks::CompetingInterestsTask')
    end

    def financial_disclosure
      task('TahiStandardTasks::FinancialDisclosureTask')
    end

    def data_availability
      task('TahiStandardTasks::DataAvailabilityTask')
    end

    def serializable_hash
      fail Typesetter::MetadataError.not_accepted unless valid?
      super
    end
  end
end
