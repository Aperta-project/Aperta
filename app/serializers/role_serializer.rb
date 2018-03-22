# RoleSerializer is responsible for serializing a Role model as an API response.
class RoleSerializer < AuthzSerializer
  attributes :id, :name, :assigned_to_type_hint
  has_one :journal, embed: :id

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
