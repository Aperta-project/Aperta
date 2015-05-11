module Tahi
  module <%= @plugin_short.camelize %>
    class <%= class_name %>TasksPolicy < ::TasksPolicy
    end
  end
end
