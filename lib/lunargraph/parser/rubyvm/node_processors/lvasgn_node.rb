# frozen_string_literal: true

module Lunargraph
  module Parser
    module Rubyvm
      module NodeProcessors
        class LvasgnNode < Parser::NodeProcessor::Base
          def process
            # here = get_node_start_position(node)
            here = Position.new(node.first_lineno - 1, node.first_column)
            presence = Range.new(here, region.closure.location.range.ending)
            loc = get_node_location(node)
            locals.push Lunargraph::Pin::LocalVariable.new(
              location: loc,
              closure: region.closure,
              name: node.children[0].to_s,
              assignment: node.children[1],
              comments: comments_for(node),
              presence: presence
            )
            process_children
          end
        end
      end
    end
  end
end
