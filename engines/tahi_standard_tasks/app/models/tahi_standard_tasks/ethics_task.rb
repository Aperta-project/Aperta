module TahiStandardTasks
  class EthicsTask < Task
    include MetadataTask
    DEFAULT_TITLE = 'Ethics Statement'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze
  end
end
