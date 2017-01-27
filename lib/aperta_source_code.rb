require 'ripper'

# require all ruby files under aperta_source_code_visitors/
Dir[File.dirname(__FILE__) + '/aperta_source_code_visitors/**/*.rb'].each do |path|
  require_dependency Pathname.new(path).relative_path_from(Rails.root.join('lib'))
end

# ApertaSourceCode is a wrapper the Ripper library from Ruby's standard library.
# Ripper provides a way to get S-expressions about Ruby code. The ApertaSourceCode
# class lets you give it a visitor so you can walk various bits of Ruby source
# code.
#
# It is currently being used in some specs to ensure that certain conventions
# are being followed. For an example, see application_mailer_spec.rb
class ApertaSourceCode
  def initialize(visitor)
    @visitor = visitor
  end

  def walk_file(path)
    contents = File.read(path)
    sexp_tree = Ripper.sexp(contents)
    walk_tree(sexp_tree)
  end

  def walk_tree(tree)
    head = tree[0]
    tail = tree[1..-1]
    node = nil

    if head.is_a?(Array)
      walk_tree(head)
    elsif head.is_a?(Symbol)
      node = head
    end

    if node
      visitor_method = "visit_#{node}"
      if @visitor.respond_to?(visitor_method)
        @visitor.send(visitor_method, node, tail)
      end
      @visitor.visit(node, tail)
    end

    if tail.is_a?(Array)
      walk_tree(tail)
    end

    if node
      leaving_method = "leaving_#{node}"
      if @visitor.respond_to?(leaving_method)
        @visitor.send(leaving_method, node, tail)
      end
      @visitor.leaving(node, tail)
    end
  end
end
