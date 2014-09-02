require "thread_safe"
require "active_record"

require "multi_connection/version"

module MultiConnection
  module ConnectionHandling
    def clear_active_connections!
      connection_handler.clear_active_connections!
      ghost_connection_handler.clear_active_connections!
    end

    def clear_reloadable_connections!
      connection_handler.clear_reloadable_connections!
      ghost_connection_handler.clear_reloadable_connections!
    end

    def clear_all_connections!
      connection_handler.clear_all_connections!
      ghost_connection_handler.clear_all_connections!
    end

    # spec - a symbole or string
    def switch_to(spec)
      old_handler = connection_handler
      self.connection_handler = ghost_connection_handler
      self.connection_handler.spec = spec
      yield
    ensure
      self.connection_handler.spec = nil
      self.connection_handler = old_handler
    end

    private

    def ghost_connection_handler
      @ghost_connection_handler ||=
        ::MultiConnection::ConnectionAdapters::ConnectionHandler.new
    end
  end

  module ConnectionAdapters
    class ConnectionHandler < ::ActiveRecord::ConnectionAdapters::ConnectionHandler
      attr_accessor :spec

      def initialize
        @spec_to_pool = ThreadSafe::Cache.new(:initial_capacity => 2)
      end

      def connection_pool_list
        @spec_to_pool.values.compact
      end

      def establish_connection(owner, spec)
        @spec_to_pool[self.spec] = ::ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec)
      end

      def remove_connection(spec)
        if pool = @spec_to_pool[spec]
          pool.automatic_reconnect = false
          pool.disconnect!
          pool.spec.config
        end
      end

      def retrieve_connection_pool(klass=nil)
        # Base.establish_connection will resolve the spec for us 
        # and call our #establish_connection method
        @spec_to_pool[spec] || ::ActiveRecord::Base.establish_connection(spec)
      end
    end

  end
end

