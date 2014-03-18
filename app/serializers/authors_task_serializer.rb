class AuthorsTaskSerializer < TaskSerializer
  has_many :authors, serializer: UserSerializer, embed: :ids, include: true, root: :users
end
