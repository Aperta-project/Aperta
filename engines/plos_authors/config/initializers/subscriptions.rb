Subscriptions.configure do
  add 'author:updated', PlosAuthors::PlosAuthor::Updated::NotifyPlosAuthorChange
  add 'plos_authors/plos_author:created', PlosAuthors::PlosAuthor::Created::EventStream
  add 'plos_authors/plos_author:updated', PlosAuthors::PlosAuthor::Updated::EventStream, PlosAuthors::PlosAuthor::Updated::NotifyAuthorChange
  add 'plos_authors/plos_author:destroyed', PlosAuthors::PlosAuthor::Destroyed::EventStream
end
