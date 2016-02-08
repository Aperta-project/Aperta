module TahiStandardTasks
  class TaxonTask < ::Task
    include MetadataTask
    DEFAULT_TITLE = 'New Taxon'
    DEFAULT_ROLE = 'author'
  end
end
