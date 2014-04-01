module StandardTasks
  class AuthorsTask < Task
    title "Add Authors"
    role "author"

    def authors
      paper.authors.map { |a| a.slice(:first_name, :last_name, :email, :affiliation) }
    end

    def assignees
      []
    end
  end
end
