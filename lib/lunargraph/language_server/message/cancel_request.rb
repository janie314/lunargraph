# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      class CancelRequest < Base
        def process
          host.cancel params['id']
        end
      end
    end
  end
end
