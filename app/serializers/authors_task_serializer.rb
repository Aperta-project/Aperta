class AuthorsTaskSerializer < ::TaskSerializer
  has_many :authors, embed: :ids, include: true
end
