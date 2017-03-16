# The CardSerializer is only used in an admin context at the moment. All of the
# card content for the latest version of the given card is serialized down as a
# single nested structure
class CardSerializer < ActiveModel::Serializer
  attributes :id, :name, :journal_id, :admin_content

  def admin_content
    CardContentSerializer.new(
      object.content_root_for_version(object.latest_version),
      root: false,
      admin: true
    ).as_json
  end
end
