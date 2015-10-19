class Snapshot::AuthorTaskSerializer < Snapshot::BaseTaskSerializer
  def snapshot
    snapshot_children "authors", "author", snapshot_authors, "properties"
  end

  def snapshot_authors
    authors = []
    @task.authors.order(:position).each do |author|
      author_serializer = Snapshot::AuthorSerializer.new author
      #authors << { author: author_serializer.snapshot }
      authors << author_serializer.snapshot
    end
    authors
  end

end
