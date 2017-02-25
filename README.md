# RipperTree

[![Build Status](https://travis-ci.org/siman-man/ripper_tree.svg?branch=master)](https://travis-ci.org/siman-man/ripper_tree)

RipperTree is like `tree` command for Ripper#sexp.

## Installation

```
$ gem install ripper_tree
```

## Usage

You can use `rtree` command.

sample.rb

```ruby
1 + 1
```

exec `rtree` command.

```
$ rtree sample.rb
```

result

```ruby
:program
 └──── :binary
         ├──── :@int ["1"] 1:0
         ├──── :+
         └──── :@int ["1"] 1:4
```

if use in ruby code.

```rb
require 'ripper_tree'
require 'pp'

code =<<-CODE
puts "hello world"
CODE

pp Ripper.sexp(code)
puts
puts RipperTree.create(code)
```

result

```ruby
[:program,
 [[:command,
   [:@ident, "puts", [1, 0]],
   [:args_add_block,
    [[:string_literal,
      [:string_content, [:@tstring_content, "hello world", [1, 6]]]]],
    false]]]]

:program
 └──── :command
         ├──── :@ident ["puts"] 1:0
         └──── :args_add_block
                 ├──── :string_literal
                 │       └──── :string_content
                 │               └──── :@tstring_content ["hello world"] 1:6
                 └──── false
```

and can use `-e "command"` option

```
$ rtree -e "1+2*3"
```

result

```ruby
:program
 └──── :binary
         ├──── :@int ["1"] 1:0
         ├──── :+
         └──── :binary
                 ├──── :@int ["2"] 1:2
                 ├──── :*
                 └──── :@int ["3"] 1:4
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/siman-man/ripper_tree. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
