module AuthorsList
  extend ActiveSupport::Concern

  def authors_list
    paper.authors.map.with_index { |author, index|
      author_line = "#{index + 1}. #{author.last_name}, #{author.first_name}"
      author_line += " from #{author.affiliation}" if author.affiliation
      author_line
    }.join("\n")
  end
end
