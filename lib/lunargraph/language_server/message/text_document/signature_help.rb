# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module TextDocument
        class SignatureHelp < TextDocument::Base
          def process
            line = params['position']['line']
            col = params['position']['character']
            suggestions = host.signatures_at(params['textDocument']['uri'], line, col)
            set_result({
                         signatures: suggestions.flat_map(&:signature_help)
                       })
          rescue FileNotFoundError => e
            Logging.logger.warn "[#{e.class}] #{e.message}"
            Logging.logger.warn e.backtrace.join("\n")
            set_result nil
          end
        end
      end
    end
  end
end
