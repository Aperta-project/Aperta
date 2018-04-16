# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
      json = ActiveModel::ArraySerializer.new(collection,
                                              root: root,
                                              scope: current_user).as_json
      json[:tasks] ||= []
      json[:tasks].unshift(@task.active_model_serializer
        .new(@task, scope: current_user).as_json[:task])
      json[:tasks] = json[:tasks].uniq { |task| task[:id] }
      json
    end
  end
end
