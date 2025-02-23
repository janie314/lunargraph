# frozen_string_literal: true

module Lunargraph
  module Parser
    module Rubyvm
      module NodeProcessors
        class SclassNode < Parser::NodeProcessor::Base
          def process
            sclass = node.children[0]
            if sclass.is_a?(RubyVM::AbstractSyntaxTree::Node) && sclass.type == :SELF
              closure = region.closure
            elsif sclass.is_a?(RubyVM::AbstractSyntaxTree::Node) && %i[CDECL CONST].include?(sclass.type)
              names = [region.closure.namespace, region.closure.name]
              names << sclass.children[0].to_s if names.last != sclass.children[0].to_s
              name = names.reject(&:empty?).join('::')
              closure = Lunargraph::Pin::Namespace.new(name: name, location: region.closure.location)
            else
              return
            end
            pins.push Lunargraph::Pin::Singleton.new(
              location: get_node_location(node),
              closure: closure
            )
            process_children region.update(visibility: :public, scope: :class, closure: pins.last)
          end
        end
      end
    end
  end
end
