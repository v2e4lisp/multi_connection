require "multi_connection/version"
require "thread_safe"
require "active_support/core_ext/class/attribute"
require "active_support/concern"

module MultiConnection
  module ConnectionAdapters
    class ConnectionHandler < ::ActiveRecord::ConnectionAdapters::ConnectionHandler
      def initialize
        @spec_to_pool = ThreadSafe::Cache.new(:initial_capacity => 2)
      end

      def connection_pool_list
        spec_to_pool.values.compact
      end

      def establish_connection(owner, spec)
        spec_to_pool[spec.name] =
          ::ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec)
      end

      def remove_connection(spec_name)
        if pool = spec_to_pool[spec_name]
          pool.automatic_reconnect = false
          pool.disconnect!
          pool.spec.config
        end
      end

      def retrieve_connection_pool(klass)
        if spec = spec_name_for(klass)
          spec_to_pool[spec]
        end
      end

      private

      def spec_to_pool
        @spec_to_pool
      end

      def spec_name_for(klass)
        klass.db_to_swtich
      end
    end
  end
end

module MultiConnection
  module ConnectionHandling
    included { class_attribute :db_to_switch, instance_predicate: false }

    module ClassMethods
      def switch_to(spec)
        raise "ActiveRecord::Base.switch_to cannnot be nested" if db_to_swtich?

        old_handler = self.connection_handler
        self.connection_handler = gost_connection_handler
        db_to_switch = spec
        yield
      ensure
        db_to_switch = nil
        self.connection_handler = old_handler
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

      def gost_connection_handler
        @gost_connection_handler ||=
          MultiConnection::ConnectionAdapters::ConnectionHandler.new
      end
    end
  end
end

# TODO
# ConnectionManager

class ActiveRecord::Base
  extend MultiConnection::ConnnectionHandling
end

# def clear_active_connections!
#   connection_handler.clear_active_connections!
#   gost_connection_handler.clear_active_connections!
# end
