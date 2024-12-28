# frozen_string_literal: true

require 'fileutils'

module Lunargraph
  module Cache
    class << self
      # The base directory where cached documentation is installed.
      #
      # @return [String]
      def base_dir
        # The directory is not stored in a variable so it can be overridden
        # in specs.
        ENV['LUNARGRAPH_CACHE'] ||
          (ENV['XDG_CACHE_HOME'] ? File.join(ENV['XDG_CACHE_HOME'], 'lunargraph') : nil) ||
          File.join(Dir.home, '.cache', 'lunargraph')
      end

      # The working directory for the current Ruby and Lunargraph versions.
      #
      # @return [String]
      def work_dir
        # The directory is not stored in a variable so it can be overridden
        # in specs.
        File.join(base_dir, "ruby-#{RUBY_VERSION}", "rbs-#{RBS::VERSION}", "lunargraph-#{Lunargraph::VERSION}")
      end

      # @return [Array<Lunargraph::Pin::Base>, nil]
      def load *path
        file = File.join(work_dir, *path)
        return nil unless File.file?(file)
        Marshal.load(File.read(file, mode: 'rb'))
      rescue StandardError => e
        Lunargraph.logger.warn "Failed to load cached file #{file}: [#{e.class}] #{e.message}"
        FileUtils.rm_f file
        nil
      end

      # @return [Boolean]
      def save *path, pins
        return false if pins.empty?
        file = File.join(work_dir, *path)
        base = File.dirname(file)
        FileUtils.mkdir_p base unless File.directory?(base)
        ser = Marshal.dump(pins)
        File.write file, ser, mode: 'wb'
        true
      end

      def clear
        FileUtils.rm_rf base_dir, secure: true
      end
    end
  end
end
