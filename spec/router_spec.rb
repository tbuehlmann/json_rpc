RSpec.describe JsonRpc::Router do
  describe '#route' do
    it 'appends to @path using a String' do
      path = nil
      subject.route('foo') { path = @path }

      expect(path).to eq('/foo')
    end

    it 'appends to @path using a Symbol' do
      path = nil
      subject.route(:foo) { path = @path }

      expect(path).to eq('/foo')
    end

    it 'ignores / at beginning and end of string' do
      path = nil
      subject.route('//foo//') { path = @path }

      expect(path).to eq('/foo')
    end

    it 'allows multiple parts in one method call' do
      path = nil
      subject.route('foo/bar/baz') { path = @path }

      expect(path).to eq('/foo/bar/baz')
    end

    it 'allows nested appending' do
      path = nil

      subject.route('foo') do
        route('bar') { path = @path }
      end

      expect(path).to eq('/foo/bar')
    end

    it 'does not change @path for an empty String' do
      path = nil
      subject.route('') { path = @path }

      expect(path).to eq('/')
    end
  end

  describe '#namespace' do
    it 'appends to @namespace using a String' do
      namespace = nil
      subject.namespace('foo') { namespace = @namespace }

      expect(namespace).to eq('foo')
    end

    it 'appends to @namespace using a String with the default namespace_separator (.)' do
      namespace = nil
      subject.namespace('foo.bar') { namespace = @namespace }

      expect(namespace).to eq('foo.bar')
    end

    it 'appends to @namespace using a Symbol' do
      namespace = nil
      subject.namespace(:foo) { namespace = @namespace }

      expect(namespace).to eq('foo')
    end

    it 'appends to @namespace using an Array (Strings and/or Symbols)' do
      namespace = nil
      subject.namespace([:foo, 'bar.baz']) { namespace = @namespace }

      expect(namespace).to eq('foo.bar.baz')
    end

    it 'appends to @namespace using a different namespace_separator' do
      subject.namespace_separator = '::'
      namespace = nil
      subject.namespace([:foo, :bar]) { namespace = @namespace }

      expect(namespace).to eq('foo::bar')
    end

    it 'ignores the namespace_separator at beginning and end of string' do
      namespace = nil
      subject.namespace('..foo..') { namespace = @namespace }

      expect(namespace).to eq('foo')
    end

    it 'does not change @namespace for an empty String' do
      namespace = nil
      subject.namespace('') { namespace = @namespace }

      expect(namespace).to eq('')
    end

    it 'allows nested appending' do
      namespace = nil

      subject.namespace('foo') do
        namespace('bar') { namespace = @namespace }
      end

      expect(namespace).to eq('foo.bar')
    end
  end

  describe '#routes' do
    it 'is empty after init' do
      expect(subject.routes).to be_empty
    end
  end

  describe '#expose' do
    let(:handler) { Class.new }
    let(:routes) { subject.routes }

    it 'exposes a handler object' do
      subject.expose(handler)
      expect(routes).to eq({'/' => {'' => [handler]}})
    end

    it 'exposes a handler object for a given route using the route method' do
      handler = handler # local variable needed for the scope

      subject.route('foo') do
        expose(handler)
      end

      expect(routes).to eq({'/foo' => {'' => [handler]}})
    end

    it 'exposes a handler object for a given namespace using the namespace method' do
      handler = handler # local variable needed for the scope

      subject.namespace('foo') do
        expose(handler)
      end

      expect(routes).to eq({'/' => {'foo' => [handler]}})
    end

    it 'exposes a handler object for a given route using the route option' do
      subject.expose(handler, route: 'foo')
      expect(routes).to eq({'/foo' => {'' => [handler]}})
    end

    it 'exposes a handler object for a given namespace using the namespace option' do
      subject.expose(handler, namespace: 'foo')
      expect(routes).to eq({'/' => {'foo' => [handler]}})
    end

    it 'exposes a handler object for a given route and namespace using methods and options' do
      handler = handler # local variable needed for the scope

      subject.route('foo') do
        namespace('foo') do
          expose(handler, route: 'bar', namespace: 'bar')
        end
      end

      expect(routes).to eq({'/foo/bar' => {'foo.bar' => [handler]}})
    end

    it 'removes handler doubles from the routes' do
      subject.expose(handler)
      subject.expose(handler)

      expect(routes['/']['']).to eq([handler])
    end
  end

  describe '#handler_and_method_for_path_and_namespaced_method' do
    let(:handler) do
      Class.new do
        include JsonRpc::Handler

        def baz; end
        expose :baz
      end
    end

    let(:another_handler) do
      Class.new do
        include JsonRpc::Handler

        def baz; end
        expose :baz
      end
    end

    it 'returns the correct handler and method for a given route and namespaced method' do
      subject.expose(handler, route: 'foo', namespace: 'bar')
      handler_and_method = subject.handler_and_method_for_path_and_namespaced_method('/foo', 'bar.baz')

      expect(handler_and_method). to eq([handler, 'baz'])
    end

    it 'returns the first matching handler' do
      subject.expose(handler, route: 'foo', namespace: 'bar')
      subject.expose(another_handler, route: 'foo', namespace: 'bar')
      handler_and_method = subject.handler_and_method_for_path_and_namespaced_method('/foo', 'bar.baz')

      expect(handler_and_method). to eq([handler, 'baz'])
    end
  end
end
