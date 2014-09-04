# MultiConnection

Multiple database connections for rails

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'multi_connection'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install multi_connection

## Usage

### API

- `switch_to(:database)` database should be defined in you `database.yml` file.

### Example

```ruby
ActiveRecord::Base.switch_to(:production_slave) {
  User.find(1)
}
```
