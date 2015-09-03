module Snapshot
  class PlosAuthorSerializer < BaseSerializer
    attr_reader :author

    def initialize(author:)
      @author = author
    end

    def snapshot
      { :name => "author", :type => "properties", :children => [
          snapshot_property("name", "text", "#{author.first_name} #{author.middle_initial} #{author.last_name}"),
          snapshot_property("email", "text", "#{author.email}"),
          snapshot_property("title", "text", "#{author.title}"),
          snapshot_property("department", "text", "#{author.department}"),
          snapshot_property("corresponding", "text", "#{author.corresponding}"),
          snapshot_property("deceased", "text", "#{author.deceased}"),
          snapshot_property("affiliation", "text", "#{author.affiliation}"),
          snapshot_property("secondary_affiliation", "text", "#{author.secondary_affiliation}")
        ]
      }
    end
  end
end
