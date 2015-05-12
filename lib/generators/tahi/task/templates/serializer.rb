module Tahi
  module <%= @plugin_short.camelize %>
    class <%= class_name %>TaskSerializer < ::TaskSerializer
    end
  end
end
