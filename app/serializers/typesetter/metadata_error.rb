module Typesetter
  # Custom error class for Typesetter::Metadata
  class MetadataError < StandardError
    class << self
      def no_task(task_type)
        new "Task `#{humanize_type(task_type)}` is required."
      end

      def multiple_tasks(task)
        new("Found multiple tasks for `#{humanize_type(task.type)}`," \
            ' but only one was expected.')
      end

      def no_answer(task, question_ident)
        new("No answer found for task `#{humanize_type(task.type)}`" \
            " and question `#{question_ident}`.")
      end

      def required_field(field)
        new "Field `#{field}` required."
      end

      def humanize_type(type_string)
        type_string.demodulize.titleize
      end
    end
  end
end
