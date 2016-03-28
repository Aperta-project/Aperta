module SalesforceServices
  class Sync
    include ActiveModel::Validations

    def self.sync!(paper:)
      new(paper: paper).sync!
    end
  end
end
