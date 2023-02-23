require 'spec_helper'

RSpec.describe Rubernetes::Operator do
  describe '#initialize' do
    context 'with default options' do
      subject { described_class.new('test', 'v1', 'tests', {}) }

      it 'should create a YAML store' do
        expect(YAML::Store).to receive(:new).with('/tmp/cache/test_v1_tests.yaml')
        subject
      end

      it 'should set default options' do
        expect(subject.instance_variable_get(:@options)).to eq(sleepTimer: 1, namespace: nil, persistence_location: '/tmp/cache')
      end
    end

    context 'with custom options' do
      subject { described_class.new('test', 'v1', 'tests', { sleepTimer: 5, namespace: 'mynamespace', persistence_location: '/tmp/custom' }) }

      it 'should create a YAML store' do
        expect(YAML::Store).to receive(:new).with('/tmp/custom/test_v1_tests.yaml')
        subject
      end

      it 'should set custom options' do
        expect(subject.instance_variable_get(:@options)).to eq(sleepTimer: 5, namespace: 'mynamespace', persistence_location: '/tmp/custom')
      end
    end
  end
end