class Snapshot::AuthorTaskSerializer < Snapshot::BaseTaskSerializer
  def snapshot
    {
      authors: snapshot_authors
    }
  end

  def snapshot_authors
    authors = []
    @task.authors.order(:position).each do |author|
      author_serializer = Snapshot::AuthorSerializer.new author
      authors << { author: author_serializer.snapshot }
    end
    authors
  end

end
