module TahiStandardTasks
  class TaxonTask < ::Task
    include MetadataTask
    DEFAULT_TITLE = 'New Taxon'.freeze
  end
end
