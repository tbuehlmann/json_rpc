require 'pry'
require_relative 'lib/json_rpc'

class Foo
  include JsonRpc::Handler

  expose_all

  def foo
    'foo'
  end
end

class App < JsonRpc::Application
  route 'v1' do
    namespace(:lala) do
      expose Foo, namespace: 'börps'
    end
  end
end

class Appp
  def call(env)
    Rack::Response.new.finish
  end
end

# binding.pry

run App.new
