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
end
