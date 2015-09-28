module Snapshot
  class AuthorTaskSerializer < BaseTaskSerializer

    def snapshot
      authors = []
      @task.authors.order(:position).each do |author|
        author_serializer = Snapshot::AuthorSerializer.new author
        authors << ["author", author_serializer.snapshot]
      end
      authors
    end
  end
end
