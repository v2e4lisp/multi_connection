require "multi_connection/version"

module MultiConnection
  def self.included(base)
    base.extend self
  end

  def switch_to(spec_name)
    self.establish_connection(spec_name)
    yield self
  ensure
    self.remove_connection
  end
end
