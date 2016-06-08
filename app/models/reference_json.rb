# Stores reference information in jsonb columns in Postgres
# This helps us avoid long hashes in our Ember code that is hard to update
# without a code change
#
# Example:
# `ReferenceJson.find_by(name: 'Institutional Account List').items`
# Will return an array of hashes
#
class ReferenceJson < ActiveRecord::Base
  def self.institutional_accounts
    find_by(name: 'Institutional Account List')
  end
end
