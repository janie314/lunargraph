# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module Workspace
        autoload :DidChangeWatchedFiles,     'lunargraph/language_server/message/workspace/did_change_watched_files'
        autoload :WorkspaceSymbol,           'lunargraph/language_server/message/workspace/workspace_symbol'
        autoload :DidChangeConfiguration,    'lunargraph/language_server/message/workspace/did_change_configuration'
        autoload :DidChangeWorkspaceFolders, 'lunargraph/language_server/message/workspace/did_change_workspace_folders'
      end
    end
  end
end
