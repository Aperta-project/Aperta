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
      204
    end

    def content
      nil
    end
  end
end
