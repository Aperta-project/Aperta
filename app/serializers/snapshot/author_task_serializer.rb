class Snapshot::AuthorTaskSerializer < Snapshot::TaskSerializer
  def as_json
    { name: "authors", type: "properties", children: snapshot_authors }
  end

  private

  def snapshot_authors
    @task.authors.order(:position).map do |author|
      Snapshot::AuthorSerializer.new(author).as_json
    end
  end
end
