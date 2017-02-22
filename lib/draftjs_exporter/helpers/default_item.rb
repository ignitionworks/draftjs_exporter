module DraftjsExporter
  module DefaultItem

    # Define method, which returns 'default' element from hashmap if it present and hashmap hasn't got 'key' element
    def has_default_item_in(map_symbol)
      self.class_eval do
        define_method :fetch_or_default_item do |key|
          if !self.__send__(map_symbol).fetch(key, nil).nil?
            self.__send__(map_symbol).fetch(key)
          elsif !self.__send__(map_symbol).fetch('default', nil).nil?
            self.__send__(map_symbol).fetch('default')
          else
            self.__send__(map_symbol).fetch(key) # Raise exception if default attr is not present, to be backward compatible
          end
        end
      end
    end

  end
end
