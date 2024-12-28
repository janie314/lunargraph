# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module Extended
        # Update YARD documentation for installed gems. If the `rebuild`
        # parameter is true, rebuild existing yardocs.
        #
        class Environment < Base
          def process
            # Make sure the environment page can report RuboCop's version
            require 'rubocop'

            page = Lunargraph::Page.new(host.options['viewsPath'])
            content = page.render('environment', layout: true, locals: { config: host.options, folders: host.folders })
            set_result(
              content: content
            )
          end
        end
      end
    end
  end
end
