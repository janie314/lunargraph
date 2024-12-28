# frozen_string_literal: true

module Lunargraph
  module Parser
    module Legacy
      module NodeProcessors
        class DefNode < Parser::NodeProcessor::Base
          def process
            methpin = Lunargraph::Pin::Method.new(
              location: get_node_location(node),
              closure: region.closure,
              name: node.children[0].to_s,
              comments: comments_for(node),
              scope: region.scope || (region.closure.is_a?(Pin::Singleton) ? :class : :instance),
              visibility: region.visibility,
              node: node
            )
            if (methpin.name == 'initialize') && (methpin.scope == :instance)
              pins.push Lunargraph::Pin::Method.new(
                location: methpin.location,
                closure: methpin.closure,
                name: 'new',
                comments: methpin.comments,
                scope: :class,
                parameters: methpin.parameters
              )
              # @todo Smelly instance variable access.
              pins.last.instance_variable_set(:@return_type, ComplexType::SELF)
              pins.push methpin
              # @todo Smelly instance variable access.
              methpin.instance_variable_set(:@visibility, :private)
              methpin.instance_variable_set(:@return_type, ComplexType::VOID)
            elsif region.visibility == :module_function
              pins.push Lunargraph::Pin::Method.new(
                location: methpin.location,
                closure: methpin.closure,
                name: methpin.name,
                comments: methpin.comments,
                scope: :class,
                visibility: :public,
                parameters: methpin.parameters,
                node: methpin.node
              )
              pins.push Lunargraph::Pin::Method.new(
                location: methpin.location,
                closure: methpin.closure,
                name: methpin.name,
                comments: methpin.comments,
                scope: :instance,
                visibility: :private,
                parameters: methpin.parameters,
                node: methpin.node
              )
            else
              pins.push methpin
            end
            process_children region.update(closure: methpin, scope: methpin.scope)
          end
        end
      end
    end
  end
end
