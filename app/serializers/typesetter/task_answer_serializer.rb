module Typesetter
  # Base class for serializers that need to interact
  # with nested question answers.
  class TaskAnswerSerializer < Typesetter::BaseSerializer
    private

    def tasks_by_type(task_type)
      object.tasks.where(type: task_type)
    end

    def custom_task(task_name)
      tasks = object.tasks.where(type: 'CustomCardTask', title: task_name)
      first_if_single(tasks)
    end

    def task(task_type)
      tasks = tasks_by_type(task_type)
      first_if_single(tasks)
    end

    def first_if_single(tasks)
      if tasks.length == 1
        tasks.first
      elsif tasks.length > 1
        raise Typesetter::MetadataError.multiple_tasks(tasks)
      else
        # This branch isn't strictly necessary, but here to raise visibility
        # that is an intentional decision.
        nil
      end
    end

    def custom_tasks_questions_answers
      tasks = object.tasks.where(type: 'CustomCardTask')
                          .includes(answers: :card_content)
      question_answers = process_answers(tasks)
    end

    # TODO: update this to handle Repetitions
    def process_answers(tasks)
      question_answers = {}
      tasks.each do |task|
        answers = task.answers
        answers.each do |answer|
          next if answer.card_content.ident.blank?
          if answer.card_content.value_type == 'attachment'
            question_answers[answer.card_content.ident.to_s] = process_file_attachments(answer)
          else
            question_answers[answer.card_content.ident.to_s] = answer.value
          end
        end
      end
      question_answers
    end

    def process_file_attachments(answer)
      title_caption = []
      answer.attachments.each do |attachment|
        title_caption << { title: attachment.title, caption: attachment.caption }
      end
      title_caption
    end
  end
end
