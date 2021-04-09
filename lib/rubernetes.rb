# frozen_string_literal: true

require 'rubernetes/version'
require 'rubernetes/kube_client'

module Rubernetes
  class Error < StandardError; end

  class MissingAuthSource < Error; end
end
