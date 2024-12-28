# frozen_string_literal: true

require 'lunargraph/language_server/error_codes'
require 'lunargraph/language_server/completion_item_kinds'
require 'lunargraph/language_server/symbol_kinds'

module Lunargraph
  # The LanguageServer namespace contains the classes and modules that compose
  # concrete implementations of language servers.
  #
  module LanguageServer
    autoload :Host,         'lunargraph/language_server/host'
    autoload :Message,      'lunargraph/language_server/message'
    autoload :UriHelpers,   'lunargraph/language_server/uri_helpers'
    autoload :MessageTypes, 'lunargraph/language_server/message_types'
    autoload :Request,      'lunargraph/language_server/request'
    autoload :Transport,    'lunargraph/language_server/transport'
  end
end
