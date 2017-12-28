module TahiStandardTasks
  module UpdateResponders
    class PaperReviewerTask < ::UpdateResponders::Task
      private
      def status
        200
      end

      def content
        generate_json_response(@task.paper.phases, :phases)
      end
    end
  end
end
