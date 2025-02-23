# frozen_string_literal: true

module Lunargraph
  module Parser
    module Legacy
      module NodeProcessors
        class BeginNode < Parser::NodeProcessor::Base
          def process
            process_children
          end
        end
      end
    end
  end
end
