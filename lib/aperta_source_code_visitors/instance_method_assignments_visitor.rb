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
    def visit_def(_node, tail)
      method_name = tail.first[1]
      @assignments_by_method_name[method_name] = {
        instance_variables: [],
        local_variables: []
      }
      @current_instance_method = @assignments_by_method_name[method_name]
    end

    def leaving_def(_node, _tail)
      @current_instance_method = nil
    end

    def visit_assign(_node, tail)
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
