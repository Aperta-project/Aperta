module ApertaSourceCodeVisitors

  # InstanceMethodAssignmentsVisitor is a visitor which keeps track of
  # instance and local variable assignments inside of instance methods
  # in a given piece of Ruby code.
  #
  # == Example Usage
  #
  #    visitor = ApertaSourceCodeVisitors::InstanceMethodAssignmentsVisitor.new
  #    walker = ApertaSourceCode.new(visitor)
  #    walker.walk_file 'path/to/some/ruby/file.rb'
  #    puts visitor.assignments_by_method_name.inspect
  #
  # == Note
  #
  # Class level instance methods are instance methods so these will be picked up:
  #
  #   class << self
  #     def foo
  #     end
  #   end
  #
  # Whereas methods defined as class/module level methods will not, e.g.:
  #
  #     def self.foo
  #     end
  #
  class InstanceMethodAssignmentsVisitor < BasicVisitor
    attr_reader :assignments_by_method_name

    def initialize
      @assignments_by_method_name = {}
    end

    # instance-method
    def visit_def(node, tail)
      method_name = tail.first[1]
      @assignments_by_method_name[method_name] = {
        instance_variables: [],
        local_variables: []
      }
      @current_instance_method = @assignments_by_method_name[method_name]
    end

    def leaving_def(node, tail)
      @current_instance_method = nil
    end

    def visit_assign(node, tail)
      if @current_instance_method
        method_definition = tail.first[1]
        case method_definition.first
          when :@ivar
            @current_instance_method[:instance_variables] << method_definition[1]
          when :@ident
            @current_instance_method[:local_variables] << method_definition[1]
        end
      end
    end
  end
end
