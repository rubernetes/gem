# frozen_string_literal: true

require_relative 'rubernetes/version'
require_relative 'rubernetes/kube_client'
require_relative 'rubernetes/operator'

module Rubernetes
  class Error < StandardError; end

  class MissingAuthSource < Error; end
end
