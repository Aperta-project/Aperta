class DeclarationTaskSerializer < TaskSerializer
  has_many :surveys, embed: :ids, include: true
end
