# User emails in aperta are not to be given out lightly.
# This serializer should only be invoked with proper authorization
class SensitiveInformationUserSerializer < AuthzSerializer
  attributes :id,
    :avatar_url,
    :email,
    :first_name,
    :full_name,
    :last_name,
    :username

  private

  def can_view?
    # This can only be used explicitly from the top level, never included from
    # another serializer.
    !options[:inside_association]
  end
end
