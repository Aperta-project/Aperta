class DeclarationTaskSerializer < TaskSerializer
  attributes :declarations

  def declarations
    "These are my declarations"
  end
end
