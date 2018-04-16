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
