##
# Stop using last_doi_issued
#
# Instead we'll search through the DB for the actual last DOI issued. This
# should hopefully put to bed any issues we have with this value getting out
# of sync at a slight cost to performance.
#
# initial_doi_number serves to handle the assignment of a journal's very first
# DOI but is afterwards totally ignored.
#
# using the word "number" in a column that is actually a string is odd, but is
# not a mistake. We use a string here to allow numbers with left padding
# (eg "0001")
class RemoveLastDoiIssuedFromJournal < ActiveRecord::Migration
  def change
    remove_column :journals, :last_doi_issued, :string, default: '0'
    add_column :journals,
               :first_doi_number,
               :string,
               default: '0000001'
  end
end
