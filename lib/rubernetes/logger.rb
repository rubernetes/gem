# frozen_string_literal: true

require 'logger'
require 'forwardable'

module Rubernetes
  # A wrapper class around Ruby Logger
  # It will automatically attach a Rubernetes specific formatter
  # which will prepend #{crd_group}/#{crd_version}/#{crd_plural}
  # to all log messages
  class Logger
    extend Forwardable
    def_delegators :@logger, :info, :debug, :error
    attr_accessor :logger

    def initialize(crd_group, crd_version, crd_plural, options)
      original_formatter = ::Logger::Formatter.new
      namespace ||= options[:namespace]
      formatter = proc do |severity, datetime, progname, msg|
        prefix = "#{crd_group}/#{crd_version}"
        prefix += "/#{namespace}" if namespace
        prefix += "/#{crd_plural}"
        "#{prefix}: #{original_formatter.call(severity, datetime, progname, msg.dump)}"
      end
      @logger = ::Logger.new($stdout)
      @logger.formatter = formatter
    end
  end
end
