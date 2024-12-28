# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module Workspace
        class WorkspaceSymbol < Lunargraph::LanguageServer::Message::Base
          include Lunargraph::LanguageServer::UriHelpers

          def process
            pins = host.query_symbols(params['query'])
            info = pins.map do |pin|
              uri = file_to_uri(pin.location.filename)
              {
                name: pin.path,
                containerName: pin.namespace,
                kind: pin.symbol_kind,
                location: {
                  uri: uri,
                  range: pin.location.range.to_hash
                },
                deprecated: pin.deprecated?
              }
            end
            set_result info
          end
        end
      end
    end
  end
end
