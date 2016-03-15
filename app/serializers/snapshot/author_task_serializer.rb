class Snapshot::AuthorTaskSerializer < Snapshot::BaseSerializer

  private

  def snapshot_properties
    model.authors.include(:author_list_item).sort_by(&:position).map do |author|
      Snapshot::AuthorSerializer.new(author).as_json
    end
  end
end
