# This class is somewhere between a service and a mixin
# I (Ben) inherited it this way, but it doesn't feel quite right
# Services should be independent actors, and in this case, DoiService is very tightly
# coupled to a journal, to the point that many methods are delegated to it
# I would consider making this a mixin at some point
class DoiService
  PUBLISHER_PREFIX_FORMAT = /[\w\d\-\.]+/
  SUFFIX_FORMAT           = %r{[^\/]+}
  DOI_FORMAT              = %r{\A(#{PUBLISHER_PREFIX_FORMAT}/#{SUFFIX_FORMAT})\z}

  attr_reader :journal

  delegate :last_doi_issued,
           :doi_publisher_prefix,
           :doi_journal_prefix,
           to: :journal

  def initialize(journal:)
    fail ArgumentError, "Journal is required" unless journal.present?
    @journal = journal
  end

  # determines if a doi string is valid
  def self.valid?(doi_string)
    !!(doi_string =~ DOI_FORMAT)
  end

  def valid?
    Doi.valid?(to_s)
  end

  def assign!
    return unless journal_doi_enabled?
    journal.with_lock do
      journal.update! last_doi_issued: last_doi_issued.succ
    end
  end

  def next_doi!
    if journal_has_doi_prefixes?
      journal.next_doi_number!
      to_s
    end
  end

  def to_s
    [doi_publisher_prefix, suffix].join("/")
  end

  def journal_has_doi_prefixes?
    doi_publisher_prefix.present? && doi_journal_prefix.present?
  end

  def journal_doi_info_valid?
    DoiService.valid?(to_s)
  end

  private

  def prefix
    doi_publisher_prefix
  end

  def suffix
    [doi_journal_prefix, last_doi_issued].join(".")
  end
end
