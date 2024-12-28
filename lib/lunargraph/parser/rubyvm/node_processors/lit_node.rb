# frozen_string_literal: true

module Lunargraph
  module Parser
    module Rubyvm
      module NodeProcessors
        class LitNode < Parser::NodeProcessor::Base
          def process
            return unless node.children[0].is_a?(Symbol)
            pins.push Lunargraph::Pin::Symbol.new(
              get_node_location(node),
              ":#{node.children[0]}"
            )
          end
        end
      end
    end
  end
end
