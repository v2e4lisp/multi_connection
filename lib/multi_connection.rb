require "thread_safe"
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

    # Connect to another database.
    # And restore the previous connection at the end of the block.
    #
    # spec - a symbol or string
    #
    # Note, #switch_to will change the connection handler which means
    # all subsequent queries in that block will be sent to the new
    # database.
    #
    #   ActiveRecord::Base.switch_to(:another_db) {
    #     # query sent to another_db
    #   }
    #
    # This is thread safe since connection_handler is local to current
    # thread according to ActiveSupport::PerThreadRegistry.
    # 
    # Yield a block
    def switch_to(spec)
      old_handler = connection_handler
      self.connection_handler = ghost_connection_handler
      self.connection_handler.spec = spec
      yield
    ensure
      self.connection_handler.spec = nil
      self.connection_handler = old_handler
    end
    alias_method :open, :switch_to

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
        @spec_to_pool[self.spec] =
          ::ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec)
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

begin
  require 'rails'
  require 'multi_connection/railtie'
rescue LoadError
end

