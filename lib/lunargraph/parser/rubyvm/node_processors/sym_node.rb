# frozen_string_literal: true

module Lunargraph
  module Parser
    module Rubyvm
      module NodeProcessors
        class SymNode < Parser::NodeProcessor::Base
          def process
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
