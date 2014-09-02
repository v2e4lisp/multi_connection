require "multi_connection/version"
require "thread_safe"
require "active_support/core_ext/class/attribute"
require "active_support/concern"

module MultiConnection
  module ConnectionHandling
    included { class_attribute :db_to_switch, instance_predicate: false }

    module ClassMethods
      def switch_to(spec)
        raise "ActiveRecord::Base.switch_to cannnot be nested" if db_to_swtich?

        self.connection_handler = ghost_connection_handler
        db_to_switch = spec
        yield
      ensure
        db_to_switch = nil
        remove_method :connection_handler unless self == ActiveRecord::Base
      end

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

      private

      def db_to_swtich?
        klass = self
        while klass <= ActiveRecord::Base
          return true if klass.db_to_switch
          klass = klass.superclass
        end
        false
      end

      def ghost_connection_handler
        @ghost_connection_handler ||=
          MultiConnection::ConnectionAdapters::ConnectionHandler.new
      end
    end
  end

  module ConnectionAdapters
    class ConnectionHandler < ::ActiveRecord::ConnectionAdapters::ConnectionHandler
      def initialize
        @spec_to_pool = ThreadSafe::Cache.new(:initial_capacity => 2)
      end

      def connection_pool_list
        @spec_to_pool.values.compact
      end

      def establish_connection(owner, spec)
        @spec_to_pool[spec.name] =
          ::ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec)
      end

      def remove_connection(spec_name)
        if pool = @spec_to_pool[spec_name]
          pool.automatic_reconnect = false
          pool.disconnect!
          pool.spec.config
        end
      end

      def retrieve_connection_pool(klass)
        if spec = spec_name_for(klass)
          @spec_to_pool[spec]
        end
      end

      private

      def spec_name_for(klass)
        klass.db_to_swtich
      end
    end

    ConnectionManager
  end
end

class ActiveRecord::Base
  extend MultiConnection::ConnnectionHandling
end
