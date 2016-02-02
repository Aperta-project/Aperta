namespace :data do
  namespace :migrate do
    namespace :author_reviewers do
      desc 'Migrates the Author and Reviewer old_roles to the new roles'
      task make_into_new_roles: :environment do
        Rake::Task['data:migrate:author_reviewers:remove_invalid_assignments'].invoke

        # Assign every Author and Reviewer role
        Paper.all.each do |paper|
          journal = paper.journal
          author_role = journal.roles.author
          reviewer_role = journal.roles.reviewer
          user = paper.creator
          puts "Assigning #{user.full_name} <#{user.email}> as #{author_role.name} on paper ##{paper.id} on '#{journal.name}' Journal"
          Assignment.where(
            user: paper.creator,
            role: author_role,
            assigned_to: paper
          ).first_or_create!
          paper.paper_roles.each do |paper_role|
            if paper_role.old_role == 'reviewer'
              puts "Assigning #{user.full_name} <#{user.email}> as #{reviewer_role.name} on paper ##{paper.id} on '#{journal.name}' Journal"
              Assignment.where(
                user: paper_role.user,
                role: reviewer_role,
                assigned_to: paper
              ).first_or_create!
            else
              next
            end
          end
        end
      end

      desc 'Removes invalid author role assignments'
      task remove_invalid_assignments: :environment do
        all_author_roles = Role.where(name: 'Author').all

        Paper.all.each do |paper|
          journal = paper.journal
          author_role = journal.roles.author

          # Remove invalid author roles for this paper and its journal
          author_roles_that_should_not_exist = all_author_roles - [author_role]
          Assignment.where(
            role_id: author_roles_that_should_not_exist,
            assigned_to: paper
          ).destroy_all
        end
      end

      desc 'Sets billing task permission on JournalTaskType'
      task make_billing_only_for_author: :environment do
        view_permission = Permission.find_by!(
          applies_to: 'PlosBilling::BillingTask', action: 'view'
        )
        edit_permission = Permission.find_by!(
          applies_to: 'PlosBilling::BillingTask', action: 'edit'
        )

        PlosBilling::BillingTask.all.each do |task|
          task.permission_requirements.where(
            permission_id: view_permission.id
          ).first_or_create!
          task.permission_requirements.where(
            permission_id: edit_permission.id
          ).first_or_create!
        end

        billing = JournalTaskType.find_by(kind: "PlosBilling::BillingTask")
        billing.update_columns(
          required_permissions: [
            { action: 'view', applies_to: 'PlosBilling::BillingTask' }
          ]
        )
      end
    end
  end
end
