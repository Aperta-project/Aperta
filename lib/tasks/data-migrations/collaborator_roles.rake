# rubocop:disable all

namespace :data do
  namespace :migrate do
    namespace :collaborators do
      desc 'Migrates paper collaborators to use new R&P task assignments'
      task make_into_new_roles: :environment do
        PaperRole.collaborators.each do |paper_role|
          paper = paper_role.paper
          user = paper_role.user
          collaborator_role = paper.journal.roles.collaborator

          if paper && user
            if user != paper.creator
              puts "Assigning #{user.full_name} <#{user.email}> as Collaborator on '#{paper.title}' Paper"
              Assignment.where(
                assigned_to: paper,
                user: user,
                role: collaborator_role
              ).first_or_create!
            end
          else
            paper_role.destroy
          end
        end
      end
    end
  end
end
