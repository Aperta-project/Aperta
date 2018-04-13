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
  class BasicVisitor
    # This method is required
    def visit(node, tail)
      # no-op for visiting any node
    end

    # This method is required
    def leaving(node, tail)
      # no-op for leaving any node
    end

    ######################################
    # OPTIONAL visit/leaving methods
    ######################################

    def visit_def(node, tail)
      # no-op for entering an instance method definition
    end

    def leaving_def(node, tail)
      # no-op for leaving instance method definition
      # Note: this will also pick up class instance methods defined in
      # code written like this:
      #    "class << self ; def foo ; end ; end"
    end

    def visit_assign(node, tail)
      # no-op for variable assignments  (both ivar and local var)
    end

    def leaving_assign(node, tail)
      # no-op for leaving variable assignments (both ivar and local var)
    end

    def visit_class(node, tail)
      # no-op for visiting a class definition
    end

    def leaving_class(node, tail)
      # no-op for leaving a definition definition
    end

    def visit_defs(node, tail)
      # no-op for visiting a class methods defined with "def self.method_name"
    end

    def leaving_defs(node, tail)
      # no-op for for class methods defined with "def self.method_name"
    end
  end
end
