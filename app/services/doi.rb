class Doi
  PUBLISHER_PREFIX_FORMAT = /[\w\d\-\.]+/
  SUFFIX_FORMAT = /[^\/]+/
  FORMAT = %r{\A(#{PUBLISHER_PREFIX_FORMAT}/#{SUFFIX_FORMAT})\z}

  attr_reader :journal

  delegate :last_doi_issued,
           :doi_publisher_prefix,
           :doi_journal_prefix,
           to: :journal

  def initialize(journal:)
    @journal = journal
  end

  def self.valid?(doi_string)
    String(doi_string).match(FORMAT)
    $1 == String(doi_string)
  end

  def assign!
    return unless journal_has_doi?
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

  def journal_has_doi?
    doi_publisher_prefix.present? && doi_journal_prefix.present?
  end
end
