module StandardTasks
  class TaxonTask < ::Task
    title "New Taxon"
    role "author"

    def active_model_serializer
      TaskSerializer
    end
  end
end
