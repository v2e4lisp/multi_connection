# MultiConnection

TODO: Write a gem description

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

```ruby
ActiveRecord::Base.switch(:production_slave) {
  User.find(1)
}
```
