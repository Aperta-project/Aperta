# This creates the json representation of individual authors for use in
# versioning and diffing. Triggered on the paper submitted event.
class Snapshot::AuthorTaskSerializer < Snapshot::BaseSerializer
  private

  def snapshot_properties
    authors = model.authors
              .includes(:author_list_item)
              .map do |author|
      Snapshot::AuthorSerializer.new(author).as_json
    end

    group_authors = model.group_authors
                    .includes(:author_list_item)
                    .map do |author|
      Snapshot::GroupAuthorSerializer.new(author).as_json
    end

    (authors + group_authors).sort_by { |a| a[:position] }
  end
end
