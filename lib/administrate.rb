require "administrate/engine"

module Administrate
  mattr_accessor :engine_namespace
  @@engine_namespace = nil

  def self.setup
    yield self
  end
end
