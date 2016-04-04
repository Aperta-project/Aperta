module SalesforceServices
  # Sync is intended to be a base-class for sync'ing information
  # paper/manuscript(s) to Salesforce.
  class Sync
    include ActiveModel::Validations

    def self.sync!(paper:)
      new(paper: paper).sync!
    end

    def sync!(*_)
      fail NotImplementedError, '#sync! must be implemented in a subclass'
    end
  end
end
