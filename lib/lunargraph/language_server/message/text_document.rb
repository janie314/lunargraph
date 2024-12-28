# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module TextDocument
        autoload :Base,              'lunargraph/language_server/message/text_document/base'
        autoload :Completion,        'lunargraph/language_server/message/text_document/completion'
        autoload :DidOpen,           'lunargraph/language_server/message/text_document/did_open'
        autoload :DidChange,         'lunargraph/language_server/message/text_document/did_change'
        autoload :DidClose,          'lunargraph/language_server/message/text_document/did_close'
        autoload :DidSave,           'lunargraph/language_server/message/text_document/did_save'
        autoload :Hover,             'lunargraph/language_server/message/text_document/hover'
        autoload :SignatureHelp,     'lunargraph/language_server/message/text_document/signature_help'
        autoload :DiagnosticsQueue,  'lunargraph/language_server/message/text_document/diagnostics_queue'
        autoload :OnTypeFormatting,  'lunargraph/language_server/message/text_document/on_type_formatting'
        autoload :Definition,        'lunargraph/language_server/message/text_document/definition'
        autoload :DocumentSymbol,    'lunargraph/language_server/message/text_document/document_symbol'
        autoload :Formatting,        'lunargraph/language_server/message/text_document/formatting'
        autoload :References,        'lunargraph/language_server/message/text_document/references'
        autoload :Rename,            'lunargraph/language_server/message/text_document/rename'
        autoload :PrepareRename,     'lunargraph/language_server/message/text_document/prepare_rename'
        autoload :FoldingRange,      'lunargraph/language_server/message/text_document/folding_range'
        autoload :DocumentHighlight, 'lunargraph/language_server/message/text_document/document_highlight'
      end
    end
  end
end
