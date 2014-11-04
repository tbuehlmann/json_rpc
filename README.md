# json_rpc

json_rpc lets you build JSON RPC 2.0 aware Rack Applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_rpc'
```

And then execute:

```sh
$ bundle install
```

Or install it yourself as:

```sh
$ gem install json_rpc
```

## Usage

### Exposing Handlers

A Class inheriting from `JsonRpc::Application` is a Rack Application that routes incoming JSON RPC 2.0 method calls to exposed Handlers. Given a `Calculator` Handler, you can expose it like the following:

```ruby
class Application < JsonRpc::Application
  expose Calculator
end
```

Methods from `Calculator` can then be called like this: `POST / {"jsonrpc":"2.0", "id":null, "method":"add", "params":[1,2]}`.

#### Routing with a different route

You can change the URL under where a Handler is exposed like this:

```ruby
class Application < JsonRpc::Application
  # Inline:
  expose Calculator, route: 'math/calculator'
  
  # Using a block:
  route 'math/calculator' do
    expose Calculator
  end
end
```

In both cases the Handler is exposed at `/math/calculator`.

#### Namespacing methods

In case you want to expose several Handlers under the same route having methods with identical names, you can namespace the Handler methods like this:

```ruby
class Application < JsonRpc::Application
  # Inline:
  expose Calculator, namespace: 'calculator'
  expose TodoList, namespace: 'todo_list'
  
  # Using a block:
  namespace 'calculator' do
    expose Calculator
  end
  
  namespace 'todo_list' do
    expose ToDoList
  end
end
```

When using Namespaces, you have to call methods like this: `POST / {"jsonrpc":"2.0", "id":null, "method":"todo_list.add", "params":{"name":"Write specs"}}`.

If you don't want to use `.` as namespace separator, change it like this:

```ruby
class Application < JsonRpc::Application
  namespace_separator '-'

  # …
end
```

### Exposing Handler Methods

When having a `Calculator` Handler, per default no methods are exposed at all. You can decide what public instance methods you want to expose by including the `JsonRpc::Handler` Module into the Handler Class and call `.expose` in it. Example:

```ruby
class Calculator
  include JsonRpc::Handler
  
  def add(left, right)
    left + right
  end
  expose :add
end
```

You can also expose all public instance methods by using `expose_all`:

```ruby
class Calculator
  include JsonRpc::Handler
  
  expose_all
  
  def add(left, right)
    left + right
  end
end
```

This will expose the following methods: `public_instance_methods - Object.public_instance_methods`.

### Method invokation

When an Application receives a method call, it figures out how to call the method by looking at the provided params object. 

If there's no `params` object in the JSON, it calls the method without any arguments.
If `params` provides an Array, the contents are used as splat arguments.
If `params` provides a Hash, the complete Hash is used as argument.

| Params                     | Method Call                                 |
| -------------------------- | ------------------------------------------- |
| `nil`                      | `calculator.add()`                          |
| `[1, 2]`                   | `calculator.add(1, 2)`                      |
| `{"left": 1, "right": 2}`  | `calculator.add('left' => 1, 'right' => 2)` |

You can change this behaviour by overriding the Handler Class' `invoke_method` method. The default implementation looks like [this](https://github.com/tbuehlmann/json_rpc/blob/c845257bc01839d410e9a03f45dcba1187aa9853/lib/json_rpc/handler.rb#L48-L57 "Method Invokation").

Overriding `invoke_method` can also be used to allow before/around/after filtering like [this](https://gist.github.com/tbuehlmann/35a8f1564aa6f4b88624 "Filtering").

### Rails 4

Want to use an `JsonRpc` Application in a Rails 4 App?

```ruby
# lib/my_json_rpc_application.rb

class MyJsonRpcApplication < JsonRpc::Application
  route 'jsonrpc' do
    # …
  end
end
```

```ruby
# config/routes.rb

Rails.application.routes.draw do
  mount MyJsonRpcApplication.new, at: 'jsonrpc'
end
```

## Contributing

1. Fork it (https://github.com/tbuehlmann/json_rpc/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

Copyright (c) 2014 Tobias Bühlmann

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
