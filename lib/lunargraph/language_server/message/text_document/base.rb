# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module TextDocument
        class Base < Lunargraph::LanguageServer::Message::Base
          include Lunargraph::LanguageServer::UriHelpers

          attr_reader :filename

          def post_initialize
            @filename = uri_to_file(params['textDocument']['uri'])
          end
        end
      end
    end
  end
end
