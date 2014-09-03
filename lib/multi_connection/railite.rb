module MultiConnection
  class Railtie < ::Rails::Railtie
    initializer 'multi_connection', after: 'active_record.initialize_database' do
      ActiveSupport.on_load :active_record do
        ::ActiveRecord::Base.extend ::MultiConnection::ConnectionHandling
      end
    end
  end
end
