module NiceAssets
  module AbstractInterface
    def included(klass)
      klass.class_eval do
        def interface_not_implemented(method_name)
          raise NoMethodError, "Expected #{self.class} to implement method #{method_name}"
        end
      end
    end

    def implements(method_name)
      define_method(method_name) do |*args|
        if defined?(super)
          super(*args)
        else
          self.interface_not_implemented(__method__)
        end
      end
    end
  end
end
