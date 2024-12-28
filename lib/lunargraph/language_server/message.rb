# frozen_string_literal: true

require 'lunargraph'

module Lunargraph
  module LanguageServer
    # The Message namespace contains classes that implement language server
    # protocol methods.
    #
    module Message
      autoload :Base,                 'lunargraph/language_server/message/base'
      autoload :Initialize,           'lunargraph/language_server/message/initialize'
      autoload :Initialized,          'lunargraph/language_server/message/initialized'
      autoload :TextDocument,         'lunargraph/language_server/message/text_document'
      autoload :CompletionItem,       'lunargraph/language_server/message/completion_item'
      autoload :CancelRequest,        'lunargraph/language_server/message/cancel_request'
      autoload :MethodNotFound,       'lunargraph/language_server/message/method_not_found'
      autoload :MethodNotImplemented, 'lunargraph/language_server/message/method_not_implemented'
      autoload :Extended,             'lunargraph/language_server/message/extended'
      autoload :Shutdown,             'lunargraph/language_server/message/shutdown'
      autoload :ExitNotification,     'lunargraph/language_server/message/exit_notification'
      autoload :Workspace,            'lunargraph/language_server/message/workspace'

      class << self
        # Register a method name and message for handling by the language
        # server.
        #
        # @example
        #   Message.register 'initialize', Lunargraph::Message::Initialize
        #
        # @param path [String] The method name
        # @param message_class [Class<Message::Base>] The message class
        # @return [void]
        def register path, message_class
          method_map[path] = message_class
        end

        # @param path [String]
        # @return [Class<Lunargraph::LanguageServer::Message::Base>]
        def select path
          if method_map.key?(path)
            method_map[path]
          elsif path.start_with?('$/')
            MethodNotImplemented
          else
            MethodNotFound
          end
        end

        private

        # @return [Hash{String => Class<Message::Base>}]
        def method_map
          @method_map ||= {}
        end
      end

      register 'initialize',                          Initialize
      register 'initialized',                         Initialized
      register 'textDocument/completion',             TextDocument::Completion
      register 'completionItem/resolve',              CompletionItem::Resolve
      register 'textDocument/signatureHelp',          TextDocument::SignatureHelp
      register 'textDocument/didOpen',                TextDocument::DidOpen
      register 'textDocument/didChange',              TextDocument::DidChange
      register 'textDocument/didSave',                TextDocument::DidSave
      register 'textDocument/didClose',               TextDocument::DidClose
      register 'textDocument/hover',                  TextDocument::Hover
      register 'textDocument/definition',             TextDocument::Definition
      register 'textDocument/formatting',             TextDocument::Formatting
      register 'textDocument/onTypeFormatting',       TextDocument::OnTypeFormatting
      register 'textDocument/documentSymbol',         TextDocument::DocumentSymbol
      register 'textDocument/references',             TextDocument::References
      register 'textDocument/rename',                 TextDocument::Rename
      register 'textDocument/prepareRename',          TextDocument::PrepareRename
      register 'textDocument/foldingRange',           TextDocument::FoldingRange
      # register 'textDocument/codeAction',             TextDocument::CodeAction
      register 'textDocument/documentHighlight',      TextDocument::DocumentHighlight
      register 'workspace/didChangeWatchedFiles',     Workspace::DidChangeWatchedFiles
      register 'workspace/didChangeConfiguration',    Workspace::DidChangeConfiguration
      register 'workspace/didChangeWorkspaceFolders', Workspace::DidChangeWorkspaceFolders
      register 'workspace/symbol',                    Workspace::WorkspaceSymbol
      register '$/cancelRequest',                     CancelRequest
      register '$/lunargraph/document',               Extended::Document
      register '$/lunargraph/search',                 Extended::Search
      register '$/lunargraph/checkGemVersion',        Extended::CheckGemVersion
      register '$/lunargraph/documentGems',           Extended::DocumentGems
      register '$/lunargraph/downloadCore',           Extended::DownloadCore
      register '$/lunargraph/environment',            Extended::Environment
      register 'shutdown',                            Shutdown
      register 'exit',                                ExitNotification
    end
  end
end
