module JsonRpc
  class Router
    attr_writer :namespace_separator

    def initialize
      @path = root_path
      @namespace = root_namespace
    end

    def route(path, &block)
      path = sanitize_path(path)

      with_path do
        unless path.empty?
          @path.concat('/') unless root_path?
          @path.concat(path)
        end
        
        instance_exec(&block)
      end
    end

    def namespace(namespace, &block)
      namespace = sanitize_namespace(namespace)

      with_namespace do
        unless namespace.empty?
          @namespace = if root_namespace?
            namespace
          else
            [@namespace, namespace].join(namespace_separator)
          end
        end

        instance_exec(&block)
      end
    end

    def expose(handler, route: '', namespace: '')
      route(route) do
        namespace(namespace) do
          routes[@path][@namespace] ||= []
          routes[@path][@namespace] << handler
          routes[@path][@namespace].uniq!
        end
      end
    end

    def routes
      @routes ||= Hash.new { |hash, key| hash[key] = {} }
    end

    def handler_and_method_for_path_and_namespaced_method(path, namespaced_method)
      namespace, method = extract_namespace_and_method_from_namespaced_method(namespaced_method)
      path = sanitized_path(path)
      handlers = routes[path].fetch(namespace, [])
      [handlers.find { |handler| handler.exposes?(method) }, method]
    end

    private

    def with_path
      current_path = @path.dup
      yield
    ensure
      @path = current_path
    end

    def with_namespace
      current_namespace = @namespace.dup
      yield
    ensure
      @namespace = current_namespace
    end

    def root_path
      '/'
    end

    def root_path?
      @path == root_path
    end

    def root_namespace
      ''
    end

    def root_namespace?
      @namespace == root_namespace
    end

    def namespace_separator
      @namespace_separator ||= '.'
    end

    def sanitize_path(path)
      path.to_s.strip.gsub(/\A\/*|\/*\z/, '')
    end

    def sanitize_namespace(namespace)
      escaped_namespace_separator = Regexp.escape(namespace_separator)

      namespace = Array(namespace).map do |ns|
        ns.to_s.gsub(/\A#{escaped_namespace_separator}*|#{escaped_namespace_separator}*\z/, '')
      end

      namespace.join(namespace_separator)
    end

    def extract_namespace_and_method_from_namespaced_method(namespaced_method)
      parts = namespaced_method.split(namespace_separator)
      method = parts.pop
      namespace = parts.join(namespace_separator)

      [namespace, method]
    end

    def sanitized_path(path)
      path.start_with?('/') ? path : path.prepend('/')
    end
  end
end
