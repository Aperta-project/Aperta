namespace :data do
  namespace :migrate do
    namespace :author_reviewers do
      desc 'Migrates the Author and Reviewer old_roles to the new roles'
      task make_into_new_roles: :environment do
        # Add Author and Reviewer role
        Role.ensure_exists('Author', participates_in: [Task]) do |role|
          role.ensure_permission_exists(:view, applies_to: 'Task')
          role.ensure_permission_exists(:view, applies_to: 'Paper')
        end
        Role.ensure_exists('Reviewer', participates_in: [Task]) do |role|
          role.ensure_permission_exists(:view, applies_to: 'Task')
          role.ensure_permission_exists(:view, applies_to: 'Paper')
        end

        # Assign every Author and Reviewer role
        Paper.all.each do |paper|
          puts "Assigning author for #{paper.id}"
          Assignment.where(
            user: paper.creator,
            role: Role.where(name: 'Author').first,
            assigned_to: paper
          ).first_or_create!
          paper.paper_roles.each do |paper_role|
            if paper_role.old_role == 'reviewer'
              puts "Assigning reviewer
                #{paper_role.user.first_name} to #{paper.id}"
              Assignment.where(
                user: paper_role.user,
                role: Role.where(name: 'Reviewer').first,
                assigned_to: paper
              ).first_or_create!
            else
              next
            end
          end
        end
      end
    end
  end
end
