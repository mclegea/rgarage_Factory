require "factory/version"

module Factory
  class Factory
    def self.new(*fields, &block)
      
      if fields.first && fields.first.kind_of?(String)
        class_name = fields.shift
      end

      are_symbols = fields.inject(true) {|sum, item| sum &&= item.kind_of?(Symbol)}
      
      
      instance = Class.new do
        define_method :initialize do |*instance_fields|
          @data = {}
          fields.each_with_index do |field, index|
            @data[field] = instance_fields[index]
          end
        end

        fields.each do |field|
          define_method field do
            @data[field]
          end

          define_method "#{field}=".to_sym do |new_value|
            @data[field] = new_value
          end
        end

        def to_s
          inspect
        end

        def to_h
          @data
        end

        def values
          @data.values
        end

        def eql?(other)
          other.kind_of?(self.class) && self.to_h == other.to_h
        end

        def each_pair(&block)
          if block_given?
            @data.each &block
            self
          else
            @data.each
          end
        end

        def values_at(*args)
          values.values_at *args
        end

        def each(&block)
          if block_given?
            values.each &block
            self
          else
            values.each
          end
        end

        def members
          @data.keys
        end

        def select(&block)
          values.select &block
        end

        def size
          @data.size
        end

        alias_method :length, :size
        alias_method :to_a, :values
        alias_method :==, :eql?

        def [](index)
          index = get_key(index)
          @data[index]
        end

        def []=(index, value)
          key = get_key(index)
          @data[key] = value
        end

        private

        def get_key(index)
          case index
          when Symbol
            index
          when String
            index.to_sym
          when Fixnum
            members[index]
          end
        end
        
      end

      instance.class_eval &block if block_given?

      const_set(class_name, instance) if class_name

      return instance
    end
  end
end
