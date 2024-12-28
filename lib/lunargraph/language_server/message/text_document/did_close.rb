# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module TextDocument
        class DidClose < Base
          def process
            host.close params['textDocument']['uri']
          end
        end
      end
    end
  end
end
