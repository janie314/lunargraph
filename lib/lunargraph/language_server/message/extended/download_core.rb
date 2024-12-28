# frozen_string_literal: true

require 'open3'

module Lunargraph
  module LanguageServer
    module Message
      module Extended
        # Update core Ruby documentation.
        #
        class DownloadCore < Base
          def process
            host.show_message 'Downloading cores is deprecated. Lunargraph currently uses RBS for core and stdlib documentation',
                              LanguageServer::MessageTypes::INFO
          end
        end
      end
    end
  end
end
