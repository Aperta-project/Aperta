class Doi
  FORMAT = /\w+\/\w+\.\d+/
  attr_reader :journal

  delegate :last_doi_issued,
           :doi_publisher_prefix,
           :doi_journal_prefix,
           to: :journal

  def initialize(journal:)
    fail ArgumentError, "Journal is required" unless journal.present?
    @journal = journal
  end

  def self.valid?(doi_string)
    String(doi_string).match(FORMAT).present?
  end

  def assign!
    require_prefixes!
    journal.transaction do
      journal.update! last_doi_issued: last_doi_issued.succ
    end
    to_s
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

  def require_prefixes!
    fail "No publisher prefix set" unless doi_publisher_prefix.present?
    fail "No journal prefix set" unless doi_journal_prefix.present?
  end
end
