# Provides a template context for Authors
class AuthorContext < UserContext
  def self.merge_field_definitions
    super + [{ name: :author_initial },
             { name: :affiliation }]
  end

  whitelist :author_initial, :affiliation
end
