class DefaultAuthorCreator

  attr_reader :creator, :paper, :author

  def initialize(paper, creator)
    @paper = paper
    @creator = creator
  end

  def create!
    build_author
    add_affiliation_information
    add_authors_task_association
    author.save!
  end

  private

  def build_author
    @author = paper.authors.new(first_name: creator.first_name,
                                last_name: creator.last_name,
                                email: creator.email)
  end

  def assign_author_role
    Assignment.create(
      user: creator,
      role: paper.journal.roles.creator,
      assigned_to: paper
    )
  end

  def add_affiliation_information
    if creator_affiliation = creator.affiliations.by_date.first
      author.affiliation = creator_affiliation.name
      author.department = creator_affiliation.department
      author.title = creator_affiliation.title
    end
  end

  def add_authors_task_association
    author.authors_task =
      paper.tasks.find_by(type: 'TahiStandardTasks::AuthorsTask')
  end
end
