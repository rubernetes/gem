# frozen_string_literal: true

module Rubernetes
  module Auth
    # This class is used to read and parse a KUBECONFIG file.
    # It will try to read the KUBECONFIG from ENV first, otherwise it will fallback to ~/.kube/config.
    # It extracts the kube API endpoint and authentication details.
    class KubeConfig
      def initialize
        config_path = ENV.fetch('KUBECONFIG', "#{Dir.home}/.kube/config")
        config = Kubeclient::Config.read(config_path)
        @context = config.context
      end

      def api_endpoint
        @context.api_endpoint
      end

      def ssl_options
        @context.ssl_options
      end

      def auth_options
        @context.auth_options
      end
    end
  end
end
