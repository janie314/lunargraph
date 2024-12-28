# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module TextDocument
        class DocumentSymbol < Lunargraph::LanguageServer::Message::Base
          include Lunargraph::LanguageServer::UriHelpers

          def process
            pins = host.document_symbols params['textDocument']['uri']
            info = pins.map do |pin|
              result = {
                name: pin.name,
                containerName: pin.namespace,
                kind: pin.symbol_kind,
                location: {
                  uri: file_to_uri(pin.location.filename),
                  range: pin.location.range.to_hash
                },
                deprecated: pin.deprecated?
              }
              result
            end
            set_result info
          end
        end
      end
    end
  end
end
