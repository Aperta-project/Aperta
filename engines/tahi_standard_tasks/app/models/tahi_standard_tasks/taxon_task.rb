module TahiStandardTasks
  class TaxonTask < ::Task
    include MetadataTask
    register_task default_title: "New Taxon", default_role: "author"
  end
end
