namespace :data do
  namespace :migrate do
    namespace :author_reviewers do
      desc 'Migrates the Author and Reviewer old_roles to the new roles'
      task make_into_new_roles: :environment do
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

      desc 'Sets billing task permission on JournalTaskType'
      task make_billing_only_for_author: :environment do
        permission = Permission.find_by!(applies_to: 'PlosBilling::BillingTask')
        PlosBilling::BillingTask.update_all(
          required_permission_id: permission.id
        )
        billing = JournalTaskType.find_by(kind: "PlosBilling::BillingTask")
        billing.update_columns(
          required_permission_action: 'view',
          required_permission_applies_to: 'PlosBilling::BillingTask'
        )
      end
    end
  end
end
