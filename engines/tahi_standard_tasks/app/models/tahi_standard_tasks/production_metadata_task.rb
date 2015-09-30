module TahiStandardTasks
  class ProductionMetadataTask < Task

    register_task default_title: 'Production Metadata', default_role: 'admin'

    def active_model_serializer
      ProductionMetadataTaskSerializer
    end

  end
end
