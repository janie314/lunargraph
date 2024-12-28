# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module Extended
        class Search < Base
          def process
            results = host.search(params['query'])
            page = Lunargraph::Page.new(host.options['viewsPath'])
            content = page.render('search', layout: true, locals: { query: params['query'], results: results })
            set_result(
              content: content
            )
          end
        end
      end
    end
  end
end
