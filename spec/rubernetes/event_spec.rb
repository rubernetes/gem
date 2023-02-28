# frozen_string_literal: true

require 'tempfile'
require 'yaml'

RSpec.describe Rubernetes::Event do
  subject { described_class.new(event, logger, store) }

  let(:event) do
    {
      type: 'ADDED',
      object: {
        metadata: {
          uid: '123',
          resourceVersion: '1'
        },
        spec: {
          name: 'foo'
        }
      }
    }
  end

  let(:logger) { instance_double(Logger) }

  let(:store_path) do
    file = Tempfile.new
    path = file.path
    file.close
    path
  end

  let(:store) { PStore.new(store_path) }

  describe '#handle' do
    context 'when the event is not cached' do
      let(:event_handlers) { { added: ->(event) {} } }

      before do
        allow(logger).to receive(:info)
        allow(logger).to receive(:debug)
        allow(event_handlers[:added]).to receive(:call).with(event)
        allow(store).to receive(:transaction).and_yield
        allow(store).to receive(:[]).and_return(nil)
        allow(store).to receive(:[]=)
        allow(store).to receive(:commit)
      end

      it 'calls the appropriate event handler and caches the event' do
        subject.handle(event_handlers)

        expect(event_handlers[:added]).to have_received(:call).with(event)
        expect(store).to have_received(:[]=).with(event.dig(:object, :metadata, :uid),
                                                  event.dig(:object, :metadata, :resourceVersion))
        expect(store).to have_received(:commit)
      end
    end

    context 'when the event is cached' do
      let(:cached_resource_version) { '2' }
      let(:event_handlers) { { added: ->(event) {} } }

      before do
        allow(logger).to receive(:info)
        allow(logger).to receive(:debug)
        allow(event_handlers[:added]).to receive(:call).with(event)
        allow(store).to receive(:transaction).and_yield
        allow(store).to receive(:[]).with(event.dig(:object, :metadata, :uid)).and_return(cached_resource_version)
        allow(store).to receive(:commit)
      end

      it 'does not call the event handler or cache the event' do
        subject.handle(event_handlers)

        expect(event_handlers[:added]).not_to have_received(:call)
        expect(store).not_to have_received(:commit)
      end
    end
  end
end
