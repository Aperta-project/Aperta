class Doi
  FORMAT = /\w+\/\w+\.\d+/
  attr_reader :journal

  delegate :last_doi_issued, :doi_publisher_prefix, :doi_journal_prefix, to: :journal

  def initialize(journal:)
    @journal = journal
  end

  def self.valid?(doi_string)
    String(doi_string).match(FORMAT).present?
  end

  def to_s
    [prefix, suffix].join("/")
  end

  private

  def prefix
    doi_publisher_prefix
  end

  def suffix
    [doi_journal_prefix, last_doi_issued].join(".")
  end
end
