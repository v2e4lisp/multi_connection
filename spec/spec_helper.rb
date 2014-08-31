require 'active_record'
require 'multi_connection'

ActiveRecord::Base.extend MultiConnection
ActiveRecord::Base.configurations = {
  'default' => { adapter: 'sqlite3', database: 'default' },
  'db2' => { adapter: 'sqlite3', database: 'db2' },
}

class User < ActiveRecord::Base; end

def setup_db
  ActiveRecord::Base.establish_connection :db2
  ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS users')
  ActiveRecord::Base.connection.execute('CREATE TABLE users (id integer primary key autoincrement)')
  ActiveRecord::Base.establish_connection :default
  ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS users')
  ActiveRecord::Base.connection.execute('CREATE TABLE users (id integer primary key autoincrement)')
end

def remove_db_file
  `rm -f default db2`
end

RSpec.configure do |config|
  config.before(:each) { setup_db }
  config.after(:all) { remove_db_file }
end
