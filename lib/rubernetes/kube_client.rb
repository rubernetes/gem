# frozen_string_literal: true

require_relative 'auth/source'
require 'kubeclient'

module Rubernetes
  # A wrapper class around original Kubeclient https://github.com/abonas/kubeclient.
  # It will automatically create a Kubeclient from
  # a detected `serviceaccount` or `KUBECONFIG`
  class KubeClient
    KUBE_CLIENT_CLASS = ::Kubeclient::Client

    def initialize(crd_group, crd_version)
      @crd_group = crd_group
      @crd_version = crd_version
    end

    def method_missing(method, *args)
      auth_source = Auth::Source.new

      @client ||= KUBE_CLIENT_CLASS.new(
        "#{auth_source.api_endpoint}/apis/#{@crd_group}",
        @crd_version,
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
