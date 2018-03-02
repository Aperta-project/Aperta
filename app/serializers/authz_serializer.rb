class AuthzSerializer < ActiveModel::Serializer
  def attributes
    # Are we at the top level (e.g., not an has_many/has_one included
    # serialier)? If so, skip this check - it should have happened in the
    # controller.
    if !options.fetch(:not_top_level, false)
      options[:not_top_level] = true
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
