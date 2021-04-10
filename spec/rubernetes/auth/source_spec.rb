# frozen_string_literal: true

RSpec.describe Rubernetes::Auth::Source do
  subject(:source) { described_class.new }

  context 'with serviceaccount' do
    before do
      allow(File).to receive(:exist?).with(Rubernetes::Auth::ServiceAccount::TOKEN_PATH).and_return(true)
    end

    it 'uses ServiceAccount authenticator' do
      expect(source.authenticator).to be_an_instance_of(Rubernetes::Auth::ServiceAccount)
    end
  end

  context 'with default KUBECONFIG' do
    before do
      ENV['KUBECONFIG'] = nil
      kube_path = File.join(__dir__, '..', '..', 'fixtures', '.kube', 'config')
      allow(File).to receive(:read).with(
        Rubernetes::Auth::KubeConfig::KUBECONFIG_DEFAULT_PATH
      ).and_return(File.read(kube_path))
      allow(File).to receive(:exist?).with(Rubernetes::Auth::ServiceAccount::TOKEN_PATH).and_return(false)
      allow(File).to receive(:exist?).with(Rubernetes::Auth::KubeConfig::KUBECONFIG_DEFAULT_PATH).and_return(true)
    end

    it 'uses KubeConfig authenticator' do
      expect(source.authenticator).to be_an_instance_of(Rubernetes::Auth::KubeConfig)
    end
  end

  context "with ENV['KUBECONFIG']" do
    before do
      kube_file_path = File.join(__dir__, '..', '..', 'fixtures', '.kube', 'config')
      allow(ENV).to receive(:[]).with('KUBECONFIG').and_return(kube_file_path)
      allow(ENV).to receive(:fetch).with(
        'KUBECONFIG', Rubernetes::Auth::KubeConfig::KUBECONFIG_DEFAULT_PATH
      ).and_return(kube_file_path)
      allow(File).to receive(:exist?).with(Rubernetes::Auth::ServiceAccount::TOKEN_PATH).and_return(false)
      allow(File).to receive(:exist?).with(kube_file_path).and_return(true)
    end

    it 'uses KubeConfig authenticator' do
      expect(source.authenticator).to be_an_instance_of(Rubernetes::Auth::KubeConfig)
    end
  end

  context 'without authentication source' do
    before do
      allow(File).to receive(:exist?).with(Rubernetes::Auth::ServiceAccount::TOKEN_PATH).and_return(false)
      allow(File).to receive(:exist?).with(Rubernetes::Auth::KubeConfig::KUBECONFIG_DEFAULT_PATH).and_return(false)
    end

    it 'throws a MissingAuthSource exception' do
      expect { source }.to raise_exception(Rubernetes::MissingAuthSource)
    end
  end
end
