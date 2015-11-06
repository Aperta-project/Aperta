class Snapshot::AuthorTaskSerializer < Snapshot::BaseSerializer

  private

  def snapshot_properties
    model.authors.order(:position).map do |author|
      Snapshot::AuthorSerializer.new(author).as_json
    end
  end
end
