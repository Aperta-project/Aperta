module TahiStandardTasks
  # Invite mailers use raw strings and share this formatted list of authors.
  module AuthorsList
    def self.authors_list(paper)
      paper.authors.map.with_index do |author, index|
        author_line = "#{index + 1}. #{author.last_name}, #{author.first_name}"
        author_line += " from #{author.affiliation}" if author.affiliation
        author_line
      end.join("\n")
    end
  end
end
