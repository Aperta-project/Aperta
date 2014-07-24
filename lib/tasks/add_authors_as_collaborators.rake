desc "Add existing authors as paper collaborators"
task :add_authors_as_collaborators => :environment do
  all_authors = User.joins(:submitted_papers).distinct(:id)
  all_authors.each do |author|
    author.submitted_papers.each do |paper|
      PaperRole.find_or_create_by(paper: paper, user: author, role: 'collaborator')
    end
  end
end
