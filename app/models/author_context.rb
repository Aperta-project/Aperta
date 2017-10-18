class AuthorContext < UserContext
  whitelist :author_initial, :affiliation
end
