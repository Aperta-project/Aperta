namespace :data do
  namespace :migrate do
    desc "Add Abstract and title to initial submission Phase templates and reorder task templates to position it first"
    task add_abstract_and_title_to_submission: :environment do
      puts "*** Reordering Task templates ***"
      # This first action is intended to add the task Title And Abstract to the Manuscript Template managers if it
      # is not already created.
      Journal.all.each do |journal|
        # Pulls a Journal Task type of the Kind Title And Abstract
        journal_task_type = journal.journal_task_types.find_by(kind: TahiStandardTasks::TitleAndAbstractTask)

        journal.manuscript_manager_templates.each do |mtm|
          task_created = nil
          first_phase_template = nil

          # Searches on all the Phase templates for the Manuscript if the Journal task type is not created
          mtm.phase_templates.each do |pt|
            task_created ||= pt.task_templates.find_by(journal_task_type: journal_task_type)
            first_phase_template = pt if pt.position == 1
          end

          # If task is not already created, create it on the Initial submission phase
          task_created = first_phase_template.task_templates.create!(
            journal_task_type: journal_task_type,
            title: journal_task_type.title
          ) unless task_created
          p "TahiStandardTasks::TitleAndAbstractTask => "
          p task_created
          # Won't do anything if the task was already created
          next if task_created.phase_template != first_phase_template

          # Reorders tasks templates
          first_phase_template.task_templates.each do |t|
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

      # This second action is intended to add the task Title And Abstract to the papers where it was not
      # created before.
      puts "*** Reordering Tasks ***"
      Paper.all.each do |paper|
        # Searches if the task is already created
        task_to_change = paper.tasks.where(type: TahiStandardTasks::TitleAndAbstractTask).first

        # Creates the tasks and assigns to the phase, if it is not created
        next if task_to_change
        phase = paper.phases.where(position: 1).first
        task_to_change = TaskFactory.create(TahiStandardTasks::TitleAndAbstractTask, paper: paper, phase: phase)
        task_to_change.completed = true if Paper::UNEDITABLE_STATES.include? paper.publishing_state.to_sym

        p "TahiStandardTasks::TitleAndAbstractTask => "
        p task_to_change

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
end
