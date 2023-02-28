# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rubernetes::Operator do
  describe '#initialize' do
    context 'with default options' do
      subject(:test_operator) { described_class.new('test', 'v1', 'tests', {}) }

      it 'creates a YAML store' do
        expect(YAML::Store).to receive(:new).with('/tmp/cache/test_v1_tests.yaml')
        test_operator
      end

      it 'sets default options' do
        expect(test_operator.instance_variable_get(:@options)).to eq(sleepTimer: 1, namespace: nil,
                                                                     persistence_location: '/tmp/cache')
      end
    end

    context 'with custom options' do
      subject(:test_operator) do
        described_class.new('test', 'v1', 'tests',
                            { sleepTimer: 5, namespace: 'mynamespace', persistence_location: '/tmp/custom' })
      end

      it 'creates a YAML store' do
        expect(YAML::Store).to receive(:new).with('/tmp/custom/test_v1_tests.yaml')
        test_operator
      end

      it 'sets custom options' do
        expect(test_operator.instance_variable_get(:@options)).to eq(sleepTimer: 5, namespace: 'mynamespace',
                                                                     persistence_location: '/tmp/custom')
      end
    end
  end
end
