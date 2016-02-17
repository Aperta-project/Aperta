namespace :data do
  namespace :migrate do
    namespace :editors do
      desc 'Migrates the Editor(s) to new R&P Internal Editor and Academic Editor roles'
      task make_into_new_roles: [:make_journal_editors_into_new_roles, :make_paper_editors_into_new_roles]

      # desc 'Migrates the Journal Editors to new R&P Internal Editor role'
      task make_journal_editors_into_new_roles: :environment do
        # Any one who is a journal admin in the old roles gets moved to
        # the Staff Admin role in the new R&P. Likewise, any one who has
        # a role with can_view_all_manuscript_managers set to true gets
        # put into the same bucket (for now).
        OldRole.where(name: 'Editor').all.each do |old_role|
          old_role.users.each do |user|
            puts "Assigning #{user.full_name} <#{user.email}> as #{old_role.name} on '#{old_role.journal.name}' Journal"
            Assignment.where(
              user: user,
              role: old_role.journal.roles.internal_editor,
              assigned_to: old_role.journal
            ).first_or_create!
          end
        end

        OldRole.where(name: 'Handling Editor').all.each do |old_role|
          old_role.users.each do |user|
            puts "Assigning #{user.full_name} <#{user.email}> as #{old_role.name} on '#{old_role.journal.name}' Journal"
            Assignment.where(
              user: user,
              role: old_role.journal.roles.internal_editor,
              assigned_to: old_role.journal
            ).first_or_create!
          end
        end

        OldRole.where(name: 'Admin').all.each do |old_role|
          old_role.users.each do |user|
            puts "Assigning #{user.full_name} <#{user.email}> as #{old_role.name} on '#{old_role.journal.name}' Journal"
            Assignment.where(
              user: user,
              role: old_role.journal.roles.staff_admin,
              assigned_to: old_role.journal
            ).first_or_create!
          end
        end

        PaperRole.where(old_role: 'Handling Editor').includes(:user, :paper).all.each do |paper_role|
          paper = paper_role.paper
          user = paper_role.user
          Assignment.where(user: user, role: paper.journal.roles.handling_editor, assigned_to: paper).first_or_create!
        end

        PaperRole.where(old_role: ['Reviewer', 'reviewer']).includes(:user, :paper).all.each do |paper_role|
          paper = paper_role.paper
          user = paper_role.user
          Assignment.where(user: user, role: paper.journal.roles.reviewer, assigned_to: paper).first_or_create!
        end

        PaperRole.where(old_role: ['Admin', 'admin', 'Bio Staff/Admin']).includes(:user, :paper).all.each do |paper_role|
          paper = paper_role.paper
          user = paper_role.user
          Assignment.where(user: user, role: paper.journal.roles.staff_admin, assigned_to: paper).first_or_create!
        end
      end

      # desc 'Migrates the Paper Editor to new R&P Academic Editor role'
      task make_paper_editors_into_new_roles: :environment do
        # Make editors assigned to the paper Academic Editors in new R&P.
        PaperRole.where(old_role: 'editor').includes(:user, :paper).all.each do |paper_role|
          paper = paper_role.paper
          user = paper_role.user
          puts "Assigning #{user.full_name} <#{user.email}> as Academic Editor on Paper #{paper.id}"
          Assignment.where(
            user: user,
            role: paper.journal.roles.academic_editor,
            assigned_to: paper
          ).first_or_create!
        end
      end
    end
  end
end
