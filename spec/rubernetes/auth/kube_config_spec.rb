# frozen_string_literal: true

RSpec.describe Rubernetes::Auth::KubeConfig do
  subject(:authenticator) { described_class.new }

  context 'with KUBECONFIG ENV variable' do
    before do
      kube_file_path = File.join(__dir__, '..', '..', 'fixtures', '.kube', 'config')
      allow(ENV).to receive(:[]).with('KUBECONFIG').and_return(kube_file_path)
      allow(ENV).to receive(:fetch).with(
        'KUBECONFIG', described_class::KUBECONFIG_DEFAULT_PATH
      ).and_return(kube_file_path)
    end

    it "creates an object of #{described_class}" do
      expect(authenticator).not_to be_nil
    end

    it 'reads api_endpoint' do
      expect(authenticator.api_endpoint).to eq('SERVER_URL')
    end

    it 'sets cert_store in ssl_options' do
      expect(authenticator.ssl_options[:cert_store]).not_to be_nil
    end

    it 'sets auth_options as empty hash' do
      expect(authenticator.auth_options).to be_empty
    end
  end

  context "with default KUBECONFIG path #{Dir.home}/.kube/config" do
    before do
      ENV['KUBECONFIG'] = nil
      kube_path = File.join(__dir__, '..', '..', 'fixtures', '.kube', 'config')
      allow(File).to receive(:read).with(described_class::KUBECONFIG_DEFAULT_PATH).and_return(File.read(kube_path))
    end

    it "creates an object of #{described_class}" do
      expect(authenticator).not_to be_nil
    end

    it 'reads api_endpoint' do
      expect(authenticator.api_endpoint).to eq('SERVER_URL')
    end

    it 'sets cert_store in ssl_options' do
      expect(authenticator.ssl_options[:cert_store]).not_to be_nil
    end

    it 'sets auth_options as empty hash' do
      expect(authenticator.auth_options).to be_empty
    end
  end
end
