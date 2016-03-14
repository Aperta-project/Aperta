# EligibleUserService is responsible for find the users in the system that
# are eligible for various roles on a paper. This is useful when assigning
# users to various roles on a paper and you don't want a list including users
# who are already assigned to that role.
class EligibleUserService
  def self.eligible_users_for(paper:, role:)
    new(paper: paper, role: role).eligible_users
  end

  attr_reader :paper, :role

  def initialize(paper:, role:)
    @paper = paper
    @role = role
  end

  def eligible_users
    handling_editor_role = role.journal.handling_editor_role
    cover_editor_role = role.journal.cover_editor_role
    if [handling_editor_role, cover_editor_role].include?(role)
      eligible_users_for_cover_and_handling_editors
    else
      fail NotImplementedError, <<-MESSAGE.strip_heredoc
        Don't know how to find eligible users for the role:
          #{role.inspect}
        This role lookup may have been accidental. If it wasn't then finding
        eligible users for this role may need to be implemented.
      MESSAGE
    end
  end

  private

  def eligible_users_for_cover_and_handling_editors
    internal_editors = role.journal.internal_editor_role.users.uniq
    users_already_assigned = begin
      User.all
      .joins(:assignments)
      .where(assignments: { role: role, assigned_to: paper })
    end
    internal_editors - users_already_assigned
  end
end
