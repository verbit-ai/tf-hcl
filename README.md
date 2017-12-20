# Tf::Hcl

A lexer/parser/AST for the Hashicorp HCL Terraform language.  Comments are preserved via load/dump.  Think of it like `terraform fmt` for ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tf-hcl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tf-hcl 

## Usage

`bin/console`

```ruby
ast = Tf::Hcl.load_file("spec/data/variables2.tf")
puts Tf::Hcl.dump(ast)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.datapipe.net/Automation/tf-hcl.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
