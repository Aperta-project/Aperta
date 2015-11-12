module Typesetter
  # Custom error class for Typesetter::Metadata
  class MetadataError < StandardError
    class << self
      def no_task(task_type)
        new "Task `#{task_type.demodulize.titleize}` is required."
      end

      def multiple_tasks(task)
        new("Found multiple tasks for `#{task.humanize_type}`," \
            ' but only one was expected.')
      end

      def no_answer(task, question_ident)
        new("No answer found for task `#{task.humanize_type}`" \
            " and question `#{question_ident}`.")
      end

      def required_field(field)
        new "Field `#{field}` required."
      end
    end
  end
end
