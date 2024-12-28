# frozen_string_literal: true

Encoding.default_external = 'UTF-8'

require 'lunargraph/version'

# The top-level namespace for the Lunargraph code mapping, documentation,
# static analysis, and language server libraries.
#
module Lunargraph
  class InvalidOffsetError         < RangeError;    end
  class DiagnosticsError           < RuntimeError;  end
  class FileNotFoundError          < RuntimeError;  end
  class SourceNotAvailableError    < StandardError; end
  class ComplexTypeError           < StandardError; end
  class WorkspaceTooLargeError     < RuntimeError;  end
  class BundleNotFoundError        < StandardError; end
  class InvalidRubocopVersionError < RuntimeError;  end

  autoload :Position,         'lunargraph/position'
  autoload :Range,            'lunargraph/range'
  autoload :Location,         'lunargraph/location'
  autoload :Shell,            'lunargraph/shell'
  autoload :Source,           'lunargraph/source'
  autoload :SourceMap,        'lunargraph/source_map'
  autoload :ApiMap,           'lunargraph/api_map'
  autoload :YardMap,          'lunargraph/yard_map'
  autoload :Pin,              'lunargraph/pin'
  autoload :ServerMethods,    'lunargraph/server_methods'
  autoload :LanguageServer,   'lunargraph/language_server'
  autoload :Workspace,        'lunargraph/workspace'
  autoload :Page,             'lunargraph/page'
  autoload :Library,          'lunargraph/library'
  autoload :Diagnostics,      'lunargraph/diagnostics'
  autoload :ComplexType,      'lunargraph/complex_type'
  autoload :Bench,            'lunargraph/bench'
  autoload :Logging,          'lunargraph/logging'
  autoload :TypeChecker,      'lunargraph/type_checker'
  autoload :Environ,          'lunargraph/environ'
  autoload :Convention,       'lunargraph/convention'
  autoload :Documentor,       'lunargraph/documentor'
  autoload :Parser,           'lunargraph/parser'
  autoload :RbsMap,           'lunargraph/rbs_map'
  autoload :Cache,            'lunargraph/cache'

  dir = File.dirname(__FILE__)
  YARD_EXTENSION_FILE = File.join(dir, 'yard-lunargraph.rb')
  VIEWS_PATH = File.join(dir, 'lunargraph', 'views')

  # A convenience method for Lunargraph::Logging.logger.
  #
  # @return [Logger]
  def self.logger
    Lunargraph::Logging.logger
  end

  # A helper method that runs Bundler.with_unbundled_env or falls back to
  # Bundler.with_clean_env for earlier versions of Bundler.
  #
  # @return [void]
  def self.with_clean_env &block
    meth = if Bundler.respond_to?(:with_original_env)
             :with_original_env
           else
             :with_clean_env
           end
    Bundler.send meth, &block
  end
end
