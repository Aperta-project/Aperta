module UpdateResponders
  class Task
    def initialize(task, view_context)
      @task = task
      @view_context = view_context
    end

    def response
      { status: status, json: content }
    end

    private

    def current_user
      @view_context.current_user
    end

    def status
      200
    end

    def content
      generate_json_response([@task], :tasks)
    end

    def generate_json_response(collection, root)
      json = ActiveModel::ArraySerializer.new(collection, root: root, user: current_user).as_json
      json[:tasks] ||= []
      json[:tasks].unshift @task.active_model_serializer.new(@task, user: current_user).as_json[:task]
      json[:tasks] = json[:tasks].uniq { |task| task[:id] }
      json
    end
  end
end
