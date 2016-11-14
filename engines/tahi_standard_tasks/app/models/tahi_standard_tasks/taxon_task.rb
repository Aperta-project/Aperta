module TahiStandardTasks
  class TaxonTask < ::Task
    include MetadataTask
    DEFAULT_TITLE = 'New Taxon'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze
  end
end
