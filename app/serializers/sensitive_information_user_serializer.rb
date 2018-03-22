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

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
