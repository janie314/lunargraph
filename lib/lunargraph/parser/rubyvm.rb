# frozen_string_literal: true

module Lunargraph
  module Parser
    module Rubyvm
      autoload :ClassMethods, 'lunargraph/parser/rubyvm/class_methods'
      autoload :NodeChainer,  'lunargraph/parser/rubyvm/node_chainer'
      autoload :NodeMethods,  'lunargraph/parser/rubyvm/node_methods'
    end
  end
end

require 'lunargraph/parser/rubyvm/node_processors'

module RubyVM
  module AbstractSyntaxTree
    class Node
      def to_sexp
        sexp self
      end

      def == other
        return false unless other.is_a?(self.class)
        here = Lunargraph::Range.from_node(self)
        there = Lunargraph::Range.from_node(other)
        here == there && to_sexp == other.to_sexp
      end

      private

      def sexp node, depth = 0
        result = ''
        if node.is_a?(RubyVM::AbstractSyntaxTree::Node)
          result += "#{'  ' * depth}(:#{node.type}"
          node.children.each do |child|
            result += "\n#{sexp(child, depth + 1)}"
          end
          result += ')'
        else
          result += "#{'  ' * depth}#{node.inspect}"
        end
        result
      end
    end
  end
end
