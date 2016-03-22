namespace :data do
  namespace :migrate do
    namespace :ae_invitations do
      desc 'Sets the inviter for AE invit'
      task set_inviters: :environment do
        Invitation.all.includes(task: :paper).each do |invitation|
          task = invitation.task
          next unless task.is_a?(TahiStandardTasks::PaperReviewerTask)

          paper = invitation.task.paper
          if paper.academic_editors.any?
            invitation.update!(inviter: paper.academic_editors.first)
          end
        end
      end
    end
  end
end
