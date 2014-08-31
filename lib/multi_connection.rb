require "multi_connection/version"

module MultiConnection
  def self.included(base)
    base.extend self
  end

  def switch_to(spec)
    establish_connection spec
    yield self
  ensure
    remove_connection
  end
end
