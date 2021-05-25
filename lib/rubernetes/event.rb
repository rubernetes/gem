# frozen_string_literal: true

module Rubernetes
  class Event
    def initialize(event, logger, store)
      @event = event
      @logger = logger
      @store = store
    end

    def handle(methods)
      @logger.info('event received')
      @logger.debug("cached?: #{cached?.to_s}")
      return if cached?

      methods[@event[:type].downcase.to_sym].call(@event)
      cache!
    end

    private

    def cached?
      !@store.transaction { @store[cache_key] }.to_s.empty? &&
        cache.to_i >= @event[:object][:metadata][:resourceVersion].to_i
    end

    def cache
      @store.transaction { @store[cache_key] }
    end

    def cache!
      @store.transaction do
        @store[cache_key] = @event[:object][:metadata][:resourceVersion]
        @store.commit
      end
    end

    def cache_key
      @event[:object][:metadata][:uid]
    end
  end
end
