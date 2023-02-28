# frozen_string_literal: true

require_relative 'kube_client'
require_relative 'logger'
require_relative 'event'
require 'yaml'
require 'yaml/store'

module Rubernetes
  # Operator Class to run the core operator functions for your crd
  # @param group [string] Group from crd
  # @param version [string] Api Version from crd
  # @param plural [string] Name (plural) from crd
  # @param options [Hash] Additional options
  # @option options [Hash] sleepTimer Time to wait for retry if the watch event stops
  # @option options [Hash] namespace Watch only an namespace, default watch all namespaces
  # @option options [Hash] persistence_location Location for the yaml store, default is /tmp/persistence
  class Operator
    def initialize(crd_group, crd_version, crd_plural, options = {})
      # parameters
      @crd_group = crd_group
      @crd_version = crd_version
      @crd_plural = crd_plural

      # defaults
      @options = options
      @options[:sleepTimer] ||= 1
      @options[:namespace] ||= nil

      # persistence/cache layer
      @options[:persistence_location] ||= '/tmp/cache'
      Dir.mkdir(@options[:persistence_location]) unless File.exist?(@options[:persistence_location])
      @store = YAML::Store.new("#{@options[:persistence_location]}/#{@crd_group}_#{@crd_version}_#{@crd_plural}.yaml")

      # utilities
      @k8sclient = KubeClient.new(crd_group, crd_version)
      @logger = Logger.new(crd_group, crd_version, crd_plural, namespace: @options[:namespace])

      @logger.info('init the operator')
    end

    def run
      @logger.info('start the operator')

      loop do
        begin
          watcher.each do |event|
            handle_event(event)
          end
          watcher.finish
        rescue StandardError => e
          @logger.error(e.inspect)
        end

        # do not overwhelm Kube API, relax between calls
        sleep(@options[:sleepTimer])
      end
    end

    protected

    def added(event)
      @logger.info('external handler(:added) called')
      @logger.debug(event.inspect)
    end

    def modified(event)
      @logger.info('external handler(:modified) called')
      @logger.debug(event.inspect)
    end

    def deleted(event)
      @logger.info('external handler(:deleted) called')
      @logger.debug(event.inspect)
    end

    def set_status(event, patch)
      name = event.dig(:object, :metadata, :name)
      puts name
      @k8sclient.patch_entity(@crd_plural, name, { status: patch }, 'merge-patch', @options[:namespace]) and return
    end

    def get_status(event)
      resource_name = event.dig(:object, :metadata, :name)
      @k8sclient.get_entity(@crd_plural, resource_name, @options[:namespace])[:status]
    end

    private

    def handle_event(ev)
      event = Event.new(ev, @logger, @store)
      handlers = {
        added: method(:added),
        modified: method(:modified),
        deleted: method(:deleted)
      }

      event.handle(handlers)
    end

    def watcher
      @watcher ||= if @options[:namespace]
                     @k8sclient.watch_entities(@crd_plural, namespace: @options[:namespace])
                   else
                     @k8sclient.watch_entities(@crd_plural)
                   end
    end
  end
end
