module TahiStandardTasks
  class EthicsTask < Task
    include MetadataTask
    DEFAULT_TITLE = 'Ethics Statement'
    DEFAULT_ROLE = 'author'
  end
end
