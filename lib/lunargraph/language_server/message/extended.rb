# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      # Messages in the Extended module are custom to the Lunargraph
      # implementation of the language server. In the protocol, the method
      # names should start with "$/" so clients that don't recognize them can
      # ignore them, as per the LSP specification.
      #
      module Extended
        autoload :Document,        'lunargraph/language_server/message/extended/document'
        autoload :Search,          'lunargraph/language_server/message/extended/search'
        autoload :CheckGemVersion, 'lunargraph/language_server/message/extended/check_gem_version'
        autoload :DocumentGems,    'lunargraph/language_server/message/extended/document_gems'
        autoload :DownloadCore,    'lunargraph/language_server/message/extended/download_core'
        autoload :Environment,     'lunargraph/language_server/message/extended/environment'
      end
    end
  end
end
