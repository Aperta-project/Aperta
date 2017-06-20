namespace :task_templates do
  desc "Add Abstract and title to initial submission Phase templates and reorder task templates to position it first"
  task add_abstract_and_title_to_submission: :environment do
    puts "*** Reordering Task templates ***"
    Journal.all.each do |journal|
      task_types = journal.journal_task_types
      jtt = task_types.find_by(kind: TahiStandardTasks::TitleAndAbstractTask)

      journal.manuscript_manager_templates.each do |mtm|
        task_created = nil
        # Checks if the task  is not already created
        mtm.phase_templates.each do |pt|
          task_created ||= pt.task_templates.find_by(journal_task_type: jtt)
        end

        mtm.phase_templates.where(position: 1).each do |pt|
          # If task is not already created, add it to the Initial submission phase
          unless task_created
            task_created = pt.task_templates.create!(journal_task_type: jtt, title: jtt.title)
          end
          # If task is created on other phase, add to the first phase
          task_created.phase_template = pt if task_created.phase_template != pt

          # Reorders tasks templates
          pt.task_templates.each do |t|
            if t != task_created
              t.position += 1
              t.save
            else
              task_created.position = 1
              task_created.save
              break
            end
          end
        end
      end
    end

    puts "*** Reordering Tasks ***"
    Paper.all.each do |paper|
      # Searches if the task is already created
      task_to_change = paper.tasks.where(type: TahiStandardTasks::TitleAndAbstractTask).first

      # Creates the tasks and assigns to the phase, if it is not created
      next if task_to_change
      phase = paper.phases.where(position: 1).first
      task_to_change = TaskFactory.create(TahiStandardTasks::TitleAndAbstractTask, paper: paper, phase: phase)
      task_to_change.completed = true if Paper::UNEDITABLE_STATES.include? paper.publishing_state.to_sym

      # Reorder tasks
      phase.tasks.each do |t|
        if t != task_to_change
          t.position += 1
          t.save
        else
          task_to_change.position = 1
          task_to_change.save
          break
        end
      end
    end
  end
end
