# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      class MethodNotFound < Base
        def process
          set_error(
            Lunargraph::LanguageServer::ErrorCodes::METHOD_NOT_FOUND,
            "Method not found: #{request['method']}"
          )
        end
      end
    end
  end
end
