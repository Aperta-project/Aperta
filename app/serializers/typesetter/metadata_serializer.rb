module Typesetter
  # Serializes a paper's metadata for the typesetter
  # Expects a paper as its object to serialize.
  class MetadataSerializer < Typesetter::TaskAnswerSerializer
    attributes :short_title, :doi, :manuscript_id, :paper_type, :journal_title,
               :publication_date
    attribute :first_submitted_at, key: :received_date
    attribute :accepted_at, key: :accepted_date
    attribute :title, key: :paper_title

    has_one :academic_editor, serializer: Typesetter::EditorSerializer
    has_one :competing_interests,
            serializer: Typesetter::CompetingInterestsSerializer
    has_one :financial_disclosure,
            serializer: Typesetter::FinancialDisclosureSerializer
    has_one :data_availability,
            serializer: Typesetter::DataAvailabilitySerializer
    has_many :authors, serializer: Typesetter::AuthorSerializer
    has_many :supporting_information_files,
             serializer: Typesetter::SupportingInformationFileSerializer

    def academic_editor
      object.academic_editors.first
    end

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
  end
end
