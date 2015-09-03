module Snapshot
  class PlosAuthorsTaskSerializer < BaseSerializer
    attr_reader :task

    def initialize(task:)
      @task = task
    end

    def snapshot
      authors = []
      task.plos_authors.sort_by { |a| a.position }.each do |author|
        serializer = PlosAuthorSerializer.new(author: author)
        authors.push( serializer.snapshot )
      end
      authors
    end
  end
end
