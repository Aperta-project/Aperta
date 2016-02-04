# rubocop:disable all
namespace :data do
  namespace :migrate do
    desc 'Runs all of the tasks to migrate authors and reviewers to new R&P'
    task author_reviewers: [
      'author_reviewers:rename_creator_to_creator',
      'author_reviewers:remove_invalid_assignments',
      'author_reviewers:make_into_new_roles',
      'author_reviewers:make_billing_only_for_creator'
    ]

    namespace :author_reviewers do
      # desc 'Migrates the Author and Reviewer old_roles to the new roles'
      task make_into_new_roles: :environment do
        # Assign every Creator and Reviewer role
        Paper.all.each do |paper|
          journal = paper.journal
          creator_role = journal.roles.creator
          reviewer_role = journal.roles.reviewer
          user = User.find(paper.user_id)
          puts "Assigning #{user.full_name} <#{user.email}> as #{creator_role.name} on paper ##{paper.id} on '#{journal.name}' Journal"
          Assignment.where(
            user: user,
            role: creator_role,
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

      # desc 'Removes invalid creator role assignments'
      task remove_invalid_assignments: :environment do
        all_creator_roles = Role.where(name: 'Creator').all

        Paper.all.each do |paper|
          journal = paper.journal
          creator_role = journal.roles.creator

          # Remove invalid creator roles for this paper and its journal
          creator_roles_that_should_not_exist = all_creator_roles - [creator_role]
          Assignment.where(
            role_id: creator_roles_that_should_not_exist,
            assigned_to: paper
          ).destroy_all
        end
      end

      # desc 'Sets billing task permission on JournalTaskType'
      task make_billing_only_for_creator: :environment do
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

      # desc 'Rename Author role to Creator'
      task rename_creator_to_creator: :environment do
        Role.where(name: 'Author').update_all(name: 'Creator')
      end
    end
  end
end
