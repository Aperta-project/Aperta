class DOI
  FORMAT = /\b10\.(\d+\.*)+[\/](([^\s\.])+\.*)+\b/

  attr_accessor :journal

  delegate :last_doi_issued, :doi_publisher_prefix, :doi_journal_prefix, to: :journal

  def initialize(journal)
    @journal = journal
  end

  def self.valid?(str)
    str.match(FORMAT).present?
  end

  def assign!
    journal.update(last_doi_issued: next_doi_issued)
    self.to_s
  end

  def to_s
    [doi_publisher_prefix, suffix].join("/")
  end


  private

  def suffix
    [doi_journal_prefix, last_doi_issued].join(".")
  end

  def next_doi_issued
    last_doi_issued.succ
  end
end
