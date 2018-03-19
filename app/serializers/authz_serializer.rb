class AuthzSerializer < ActiveModel::Serializer
  def attributes
    # Skip authz checking for the first call only. Assume that authz happened at
    # the controller level. This is an optimization only.
    options[:inside_association] ||= false
    if !options[:inside_association]
      super
    elsif can_view?
      super
    else
      unauthorized_result
    end
  end

  def include_associations!
    orig_val = options[:inside_association]
    options[:inside_association] = true
    super
  ensure
    options[:inside_association] = orig_val
  end

  private

  def can_view?
    # Assume that if there is no scope, this is accessible
    return true if scope.nil?
    object.user_can_view?(scope)
  end

  def unauthorized_result
    { id: object.try(:id) }
  end
end
