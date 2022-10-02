# HanamiEmail

A Ruby API client for the [Hanami email forwarding service][]

## Usage

```ruby
HanamiEmail.configure do |x|
  x.default_domain = "example.com"
  x.api_key = "sk_ZX_igr4rZWD8sveAPLNJZ3jRWsuuu"
end

x = HanamiEmail::Alias.create(from: "foo", to: "bar@gmail.com")
# => {"id"=>12345, "from"=>"foo", "to"=>"bar@gmail.com", "status"=>"activated"}

x = HanamiEmail::Alias.list
# => {"data"=>[{"from"=>"foo", "to"=>"bar@gmail.com"}]}

x = HanamiEmail::Alias.delete(from: "foo", to: "bar@gmail.com")
# => {"data"=>{"success"=>true}}
```

## License

The gem is available as open source under the terms of the [MIT License][].

[Hanami email forwarding service]: https://hanami.run
[MIT License]: https://opensource.org/licenses/MIT
