# Provides a template context for Authors
class AuthorContext < UserContext
  whitelist :author_initial, :affiliation
end
