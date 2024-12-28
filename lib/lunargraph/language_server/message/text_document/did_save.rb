# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module TextDocument
        class DidSave < Base
          def process
            # @todo The server might not need to do anything in response to
            #   this notification. See https://github.com/castwide/lunargraph/issues/73
            # host.save params
          end
        end
      end
    end
  end
end
