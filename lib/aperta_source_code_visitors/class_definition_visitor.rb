module ApertaSourceCodeVisitors
  # ClassDefinitionVisitor is a visitor which keeps track of class definitions.
  # It is useful if you want to make decisions upon who a superclass
  # of a class may be.
  #
  # == Example Usage
  #
  #    visitor = ApertaSourceCodeVisitors::ClassDefinitionVisitor.new
  #    walker = ApertaSourceCode.new(visitor)
  #    walker.walk_file(mailer_path)
  #    puts visitor.class_definitions.inspect
  #
  class ClassDefinitionVisitor < BasicVisitor
    DEFAULT_SUPERCLASS = Class.new.superclass.name

    attr_reader :class_definitions

    def initialize
      @class_definitions = {}
    end

    def visit_class(node, tail)
      class_reference = tail[0]
      superclass_reference = tail[1] || nil

      if class_reference
        class_name = build_class_name_from_parts(class_reference)
        class_definition = @class_definitions[class_name] = { superclass: DEFAULT_SUPERCLASS }

        if superclass_reference
          superclass_name = build_class_name_from_parts(superclass_reference)
          class_definition[:superclass] = superclass_name
        end
      end
    end

    private

    def build_class_name_from_parts(parts)
      return nil if parts.blank?

      class_parts = []
      flattened_class_reference = parts.flatten
      flattened_class_reference.each_with_index do |n, i|
        if n == :@const
          class_parts << flattened_class_reference[i+1]
        end
      end
      class_parts.join('::')
    end
  end
end
