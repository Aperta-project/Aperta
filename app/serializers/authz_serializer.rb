class AuthzSerializer < ActiveModel::Serializer
  def attributes
    # Skip authz checking for the first call only. Assume that authz happened at
    # the controller level. This is an optimization only.
    already_called = options.fetch(:already_called, false)
    if !already_called
      options[:already_called] = true
      super
    elsif can_view?
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
