module StandardTasks
  class TaxonTask < ::Task
    register_task default_title: 'New Taxon', default_role: 'author'

    def active_model_serializer
      TaskSerializer
    end
  end
end
