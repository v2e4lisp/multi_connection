require "multi_connection/version"

module MultiConnection
  def switch_to(spec_name)
    self.establish_connection(spec_name)
    yield self
  ensure
    self.remove_connection
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.extend MultiConnection
end
