AUTHOR_EVENTS = {
  'author:updated' => [PlosAuthors::PlosAuthor::Updated::NotifyPlosAuthorChange],
  'plos_authors/plos_author:created' => [PlosAuthors::PlosAuthor::Created::EventStream],
  'plos_authors/plos_author:updated' => [PlosAuthors::PlosAuthor::Updated::EventStream, PlosAuthors::PlosAuthor::Updated::NotifyAuthorChange],
  'plos_authors/plos_author:destroyed' => [PlosAuthors::PlosAuthor::Destroyed::EventStream],
}

AUTHOR_EVENTS.each do |event_name, subscriber_list|
  Notifier.subscribe(event_name, subscriber_list)
end
