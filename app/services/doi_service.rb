# This class is somewhere between a service and a mixin
# I (Ben) inherited it this way, but it doesn't feel quite right
# Services should be independent actors, and in this case, DoiService is very tightly
# coupled to a journal, to the point that many methods are delegated to it
# I would consider making this a mixin at some point
class DoiService
  PUBLISHER_PREFIX_FORMAT = /[\w\d\-\.]+/
  SUFFIX_FORMAT           = %r{[^\/]+}
  DOI_FORMAT              = %r{\A(#{PUBLISHER_PREFIX_FORMAT}/#{SUFFIX_FORMAT})\z}

  class DoiLengthChanged < StandardError; end
  class InvalidJournalDoiConfig < StandardError; end

  def initialize(journal:)
    fail ArgumentError, "Journal is required" unless journal.present?
    @journal = journal
  end

  # determines if a doi string is valid
  def self.valid?(doi_string)
    !!(doi_string =~ DOI_FORMAT)
  end

  def journal_has_doi_prefixes?
    @journal.doi_publisher_prefix.present? &&
      @journal.doi_journal_prefix.present?
  end

  def journal_doi_info_valid?
    DoiService.valid?(first_doi)
  end

  # The DOI we'll set on the journal's very first paper
  def first_doi
    [doi_base, @journal.first_doi_number].join
  end

  # The highest DOI that matches this journal's DOI base pattern
  def last_doi
    papers_with_same_doi_base.order(:doi).last.try(:doi)
  end

  # The next unassigned DOI for this journal.
  #
  # this will raise an error if the maximum DOI has been reached. That is, this
  # will not allow the DOI to contain a different amount of characters than the
  # DOI before it, so a jump like 10/pone.99 -> 10/pone.100 is not possible.
  # In addition to keeping our DOIs from unintentionally growing, this will also
  # fail early if we lose our leading 0's.
  def next_doi
    current_last_doi = last_doi
    return first_doi unless current_last_doi
    possible_next_doi = current_last_doi.succ
    fail DoiLengthChanged if possible_next_doi.length != last_doi.length
    possible_next_doi
  end

  private

  # All papers which have a DOI which matches the DOI base pattern of this
  # journal. The scope is not limited to papers which belong to the journal.
  def papers_with_same_doi_base
    Paper.where('doi like ?', "#{doi_base}%")
  end

  # The journal's DOI base pattern--a doi without the sequential document number
  def doi_base
    "#{@journal.doi_publisher_prefix}/#{@journal.doi_journal_prefix}."
  end
end
