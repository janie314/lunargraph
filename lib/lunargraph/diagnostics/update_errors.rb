# frozen_string_literal: true

module Lunargraph
  module Diagnostics
    class UpdateErrors < Base
      def diagnose source, _api_map
        result = combine_ranges(source.code, source.error_ranges).map do |range|
          range: range.to_hash,
            severity: Diagnostics::Severities::ERROR,
            source: 'Lunargraph',
            message: 'Syntax error'
        end
      end

      private

      # Combine an array of ranges by their starting lines.
      #
      # @param code [String]
      # @param ranges [Array<Range>]
      # @return [Array<Range>]
      def combine_ranges code, ranges
        result = []
        lines = []
        ranges.sort {|a, b| a.start.line <=> b.start.line}.each do |rng|
          next if rng.nil? || lines.include?(rng.start.line)
          lines.push rng.start.line
          next if rng.start.line >= code.lines.length
          scol = code.lines[rng.start.line].index(/[^\s]/) || 0
          ecol = code.lines[rng.start.line].length
          result.push Range.from_to(rng.start.line, scol, rng.start.line, ecol)
        end
        result
      end
    end
  end
end
