# User emails in aperta are not to be given out lightly.
# This serializer should only be invoked with proper authorization
class SensitiveInformationUserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :email
end
