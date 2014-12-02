class Doi
  FORMAT = /\w+\/\w+\.\d+/
  attr_reader :journal

  def initialize(journal:)
    @journal = journal
  end

  def self.valid?(doi_string)
    String(doi_string).match(FORMAT).present?
  end
end
