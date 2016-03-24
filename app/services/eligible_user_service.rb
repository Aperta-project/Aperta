# EligibleUserService is responsible for finding users in the system that
# are eligible for various roles on a paper. This is useful when assigning
# users to various roles on a paper and you don't want a list including users
# who are already assigned to that role.
#
# === Things to note
#
# This currently does not take into account invitations.
#
class EligibleUserService
  # Returns a collection of eligible users on the given paper, for the provided
  # role, and fuzzy-matching the given matching string (optional).
  def self.eligible_users_for(paper:, role:, matching: nil)
    new(paper: paper, role: role).eligible_users(matching: matching)
  end

  attr_reader :paper, :role

  def initialize(paper:, role:)
    @paper = paper
    @role = role

    @eligible_user_blocks = {
      role.journal.academic_editor_role => -> { User.all },
      role.journal.cover_editor_role => -> { internal_editors },
      role.journal.handling_editor_role => -> { internal_editors }
    }
  end

  # Returns a collection of eligible users optionally fuzzy-matching
  # the given matching string.
  def eligible_users(matching: nil)
    block = @eligible_user_blocks.fetch(role) do
      fail NotImplementedError, <<-MESSAGE.strip_heredoc
        Don't know how to find eligible users for the role:
          #{role.inspect}
        This role lookup may have been accidental. If it wasn't then finding
        eligible users for this role may need to be implemented.
      MESSAGE
    end

    eligible_users = search(block.call, matching).to_a.uniq
    users_already_assigned = begin
      User.all
      .joins(:assignments)
      .where(assignments: { role: role, assigned_to: paper })
    end
    eligible_users - users_already_assigned
  end

  private

  def internal_editors
    role.journal.internal_editor_role.users
  end

  def search(user_relation, matching)
    return user_relation unless matching
    user_relation.fuzzy_search(matching)
  end
end
