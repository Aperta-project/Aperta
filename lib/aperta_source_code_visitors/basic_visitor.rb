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
