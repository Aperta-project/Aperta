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

  def self.eligible_for?(paper:, role:, user:)
    eligible_users_for(paper: paper, role: role).include?(user)
  end

  attr_reader :paper, :role

  def initialize(paper:, role:)
    @paper = paper
    @role = role

    @eligible_user_blocks = {
      role.journal.academic_editor_role => -> { User.all },
      role.journal.cover_editor_role => -> { internal_and_freelance_editors },
      role.journal.handling_editor_role => lambda do
        internal_and_freelance_editors
      end,
      role.journal.reviewer_role => -> { User.all },
      role.journal.staff_admin_role => -> { staff_admins }
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

    users_already_assigned_ids = User.all
      .joins(:assignments)
      .where(assignments: { role: role, assigned_to: paper })
      .select(:id)
      .pluck(:id)

    matching_users = search(block.call, matching)

    if matching_users.is_a?(Array)
      matching_not_assigned_users = matching_users.map do |users_collection|
        unless users_collection.nil?
          users_collection.where.not(id: users_already_assigned_ids).to_a
        end
      end
      matching_not_assigned_users.reject(&:nil?).flatten.uniq
    else
      matching_users.where.not(id: users_already_assigned_ids).to_a.uniq
    end

    # Trying to call .distinct on the result of
    # a search() blows up with a PG error

    # temp.where.not(id: users_already_assigned_ids)
    # temp.to_a.uniq
  end

  private

  def internal_and_freelance_editors
    [
      role.journal.internal_editor_role.users,
      role.journal.freelance_editor_role.try(:users)
    ]
  end

  # def freelance_editors
  #   freelance_editor_role.try(:users)
  #   # freelance_editor_role = role.journal.freelance_editor_role
  #   # freelance_editor_role.present? ? freelance_editor_role.users : {}
  # end
  #
  # def internal_editors
  #   role.journal.internal_editor_role.users
  # end

  def staff_admins
    role.journal.staff_admin_role.users
  end

  def search(user_relation, matching)
    return user_relation unless matching

    if user_relation.is_a?(Array)
      user_relation.map { |u| u.fuzzy_search(matching) unless u.nil? }
    else
      user_relation.fuzzy_search(matching)
    end
  end
end
