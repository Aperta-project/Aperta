class Snapshot::AuthorTaskSerializer < Snapshot::BaseTaskSerializer
  def as_json
    { name: "authors", type: "properties", children: snapshot_authors }
  end

  def snapshot_authors
    authors = []
    @task.authors.order(:position).each do |author|
      author_serializer = Snapshot::AuthorSerializer.new author
      authors << {name: "author", type: "properties", children: author_serializer.snapshot}
    end
    authors
  end
end
