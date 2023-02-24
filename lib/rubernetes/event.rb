# frozen_string_literal: true

module Rubernetes
  class Event
    attr_reader :event, :logger, :store

    def initialize(event, logger, store)
      @event = event
      @logger = logger
      @store = store
    end

    def handle(event_handlers)
      logger.info('event received')
      logger.debug("cached?: #{cached?.to_s}")
      return if cached?

      event_handlers[@event[:type].downcase.to_sym].call(event)
      cache!
    end

    private

    def cached?
      !store.transaction { store[cache_key] }.to_s.empty? &&
        cache.to_i >= event.dig(:object, :metadata, :resourceVersion).to_i
    end

    def cache
      store.transaction { store[cache_key] }
    end

    def cache!
      store.transaction do
        store[cache_key] = event.dig(:object, :metadata, :resourceVersion)
        store.commit
      end
    end

    def cache_key
      event.dig(:object, :metadata, :uid)
    end
  end
end
