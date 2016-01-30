module TahiStandardTasks
  class ProductionMetadataTask < Task

    DEFAULT_TITLE = 'Production Metadata'
    DEFAULT_ROLE = 'admin'

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

    def volume_number
      answer_for("production_metadata--volume_number").try(:value)
    end

    def issue_number
      answer_for("production_metadata--issue_number").try(:value)
    end
  end
end
