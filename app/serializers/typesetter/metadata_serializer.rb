module Typesetter
  # Serializes a paper's metadata for the typesetter
  # Expects a paper as its object to serialize.
  class MetadataSerializer < Typesetter::TaskAnswerSerializer
    alias_method :original_serializable_hash, :serializable_hash

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
    has_one :authors,
            serializer: Typesetter::AuthorsSerializer
    has_many :academic_editors, serializer: Typesetter::EditorSerializer
    has_many :supporting_information_files,
             serializer: Typesetter::SupportingInformationFileSerializer

    def journal_title
      object.journal.name
    end

    def publication_date
      production_metadata = task('TahiStandardTasks::ProductionMetadataTask')
      return unless production_metadata
      pub_date = production_metadata.publication_date
      return unless pub_date
      Date.strptime(pub_date, '%m/%d/%Y')
    end

    def provenance
      production_metadata = task('TahiStandardTasks::ProductionMetadataTask')
      return unless production_metadata
      production_metadata.provenance || ''
    end

    def special_handling_instructions
      production_metadata = task('TahiStandardTasks::ProductionMetadataTask')
      return unless production_metadata
      production_metadata.special_handling_instructions || ''
    end

    def supporting_information_files
      object.supporting_information_files.publishable
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

    def authors
      task('TahiStandardTasks::AuthorsTask')
    end

    def validate_and_serialize
      fail Typesetter::MetadataError.not_accepted unless
        object.decisions.latest.verdict == 'accept'
      original_serializable_hash
    end

    alias_method :serializable_hash, :validate_and_serialize
  end
end
