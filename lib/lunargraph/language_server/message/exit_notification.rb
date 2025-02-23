# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      class ExitNotification < Base
        def process
          host.stop
        end
      end
    end
  end
end
