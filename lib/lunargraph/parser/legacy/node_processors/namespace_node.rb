# frozen_string_literal: true

module Lunargraph
  module Parser
    module Legacy
      module NodeProcessors
        class NamespaceNode < Parser::NodeProcessor::Base
          include Legacy::NodeMethods

          def process
            sc = nil
            sc = unpack_name(node.children[1]) if (node.type == :class) && !node.children[1].nil?
            loc = get_node_location(node)
            nspin = Lunargraph::Pin::Namespace.new(
              type: node.type,
              location: loc,
              closure: region.closure,
              name: unpack_name(node.children[0]),
              comments: comments_for(node),
              visibility: :public,
              gates: region.closure.gates.freeze
            )
            pins.push nspin
            unless sc.nil?
              pins.push Pin::Reference::Superclass.new(
                location: loc,
                closure: pins.last,
                name: sc
              )
            end
            process_children region.update(closure: nspin, visibility: :public)
          end
        end
      end
    end
  end
end
