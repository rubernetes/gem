# frozen_string_literal: true

require 'rubernetes/auth/kube_config'
require 'rubernetes/auth/service_account'
require 'forwardable'

module Rubernetes
  module Auth
    # This class is used to decide on which auth mechanism to use (service_account? vs. kube_config?).
    # It helps to run Rubernetes in development/local enviornments where a serviceaccount is missing.
    class Source
      extend Forwardable
      def_delegators :@authenticator, :api_endpoint, :ssl_options, :auth_options
      attr_accessor :authenticator

      def initialize
        @authenticator = if service_account?
                           ServiceAccount.new
                         elsif kube_config?
                           KubeConfig.new
                         else
                           raise Rubernetes::MissingAuthSource, 'Could not recognize authentication source'
                         end
      end

      private

      def service_account?
        File.exist?(ServiceAccount::TOKEN_PATH)
      end

      def kube_config?
        File.exist?(kubec_onfig_path)
      end

      def kubec_onfig_path
        ENV.fetch('KUBECONFIG', "#{Dir.home}/.kube/config")
      end
    end
  end
end
