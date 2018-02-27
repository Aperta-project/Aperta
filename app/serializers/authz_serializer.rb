class AuthzSerializer < ActiveModel::Serializer
  def attributes
    if can_view?
      super
    else
      { id: object.try(:id) }.compact
    end
  end

  private

  def can_view?
    scope && object.user_can_view?(scope)
  end
end
