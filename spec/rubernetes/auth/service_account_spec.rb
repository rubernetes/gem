# frozen_string_literal: true

RSpec.describe Rubernetes::Auth::ServiceAccount do
  subject(:authenticator) { described_class.new }

  context 'with SSL' do
    before do
      allow(File).to receive(:exist?).with(described_class::CRT_PATH).and_return(true)
    end

    it "creates an object of #{described_class}" do
      expect(authenticator).not_to be_nil
    end

    it 'reads api_endpoint' do
      expect(authenticator.api_endpoint).to eq('https://kubernetes.default.svc')
    end

    it 'sets cert_store in ssl_options' do
      expect(authenticator.ssl_options[:cert_store]).to be_nil
    end

    it 'sets auth_options as empty hash' do
      expect(authenticator.auth_options).to eq({ bearer_token_file: described_class::TOKEN_PATH })
    end
  end

  context 'without SSL' do
    it "creates an object of #{described_class}" do
      expect(authenticator).not_to be_nil
    end

    it 'reads api_endpoint' do
      expect(authenticator.api_endpoint).to eq('http://kubernetes.default.svc')
    end

    it 'sets cert_store in ssl_options' do
      expect(authenticator.ssl_options[:cert_store]).to be_nil
    end

    it 'sets auth_options as empty hash' do
      expect(authenticator.auth_options).to eq({ bearer_token_file: described_class::TOKEN_PATH })
    end
  end
end
