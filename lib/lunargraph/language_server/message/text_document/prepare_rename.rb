# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module TextDocument
        class PrepareRename < Base
          def process
            line = params['position']['line']
            col = params['position']['character']
            set_result host.sources.find(params['textDocument']['uri']).cursor_at(Lunargraph::Position.new(line,
                                                                                                           col)).range.to_hash
          end
        end
      end
    end
  end
end
