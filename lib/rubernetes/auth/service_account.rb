# frozen_string_literal: true

module Rubernetes
  module Auth
    # This class is used as a serviceaccount's crt/token options wrapper.
    # It assumes that the serviceaccount crt/token is mounted at
    # `/var/run/secrets/kubernetes.io/serviceaccount`.
    class ServiceAccount
      def initialize; end

      def api_endpoint
        @api_endpoint ||= "#{ssl_options.empty? ? 'http' : 'https'}://kubernetes.default.svc"
      end

      def ssl_options
        @ssl_options ||= if File.exist?('/var/run/secrets/kubernetes.io/serviceaccount/ca.crt')
                           return { ca_file: '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt' }
                         else
                           {}
                         end
      end

      def auth_options
        @auth_options ||= {
          bearer_token_file: '/var/run/secrets/kubernetes.io/serviceaccount/token'
        }
      end
    end
  end
end
