class DoiService
  PUBLISHER_PREFIX_FORMAT = /[\w\d\-\.]+/
  SUFFIX_FORMAT = /[^\/]+/
  FORMAT = %r{\A(#{PUBLISHER_PREFIX_FORMAT}/#{SUFFIX_FORMAT})\z}

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
    String(doi_string).match(FORMAT)
    $1 == String(doi_string)
  end

  def journal_doi_info_valid?
    DoiService.valid?(to_s)
  end

  def next_doi!
    if journal_has_doi_prefixes?
      journal.transaction do
        journal.update! last_doi_issued: last_doi_issued.succ
      end
      to_s
    else
      filler_doi
    end
  end

  def to_s
    [prefix, suffix].join("/")
  end

  private

  def filler_doi
    #"nil_prefixes_#{Time.now.to_i.to_s}"
    nil
  end

  def prefix
    doi_publisher_prefix
  end

  def suffix
    [doi_journal_prefix, last_doi_issued].join(".")
  end

  def journal_has_doi_prefixes?
    doi_publisher_prefix.present? && doi_journal_prefix.present?
  end
end
