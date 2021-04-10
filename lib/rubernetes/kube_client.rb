# frozen_string_literal: true

require 'rubernetes/auth/source'
require 'kubeclient'
require 'singleton'

module Rubernetes
  # A wrapper class around original Kubeclient https://github.com/abonas/kubeclient.
  # It will automatically create a singleton Kubeclient from
  # a detected `serviceaccount` or `KUBECONFIG`
  # which can be accessed with `Rubernetes::KubeClient.instance`
  class KubeClient
    include Singleton
    API_VERSION = 'v1'
    KUBE_CLIENT_CLASS = ::Kubeclient::Client

    def method_missing(method, *args)
      auth_source = Auth::Source.new

      @client ||= KUBE_CLIENT_CLASS.new(
        auth_source.api_endpoint,
        API_VERSION,
        ssl_options: auth_source.ssl_options,
        auth_options: auth_source.auth_options
      )

      return @client.send(method, *args) if @client.respond_to?(method)

      super
    end

    def respond_to_missing?(_method_name, _include_private = false)
      super
    end
  end
end
