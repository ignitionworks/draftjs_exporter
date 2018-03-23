module DraftjsExporter
  class WrapperState
    def initialize(block_map)
      @block_map = block_map
      @document = Nokogiri::HTML::Document.new
      @fragment = Nokogiri::HTML::DocumentFragment.new(document)
      reset_wrapper
    end

    def element_for(block)
      type = block.fetch(:type, 'unstyled')

      return create_element(block_map[type]) if type != 'atomic'

      atomic_block_options = find_atomic_block_options(block)

      return create_element(block_map['unstyled']) if atomic_block_options.nil?

      create_element(atomic_block_options)
    end

    def to_s
      to_html
    end

    def to_html(options = {})
      fragment.to_html(options)
    end

    private

    attr_reader :fragment, :document, :block_map, :wrapper

    def set_wrapper(element, options = {})
      @wrapper = [element, options]
    end

    def wrapper_element
      @wrapper[0] || fragment
    end

    def wrapper_options
      @wrapper[1]
    end

    def create_element(block_options)
      document.create_element(
        block_options[:element],
        block_options.fetch(:prefix, ''),
        block_options.fetch(:attrs, {})
      ).tap do |e|
        parent_for(block_options).add_child(e)
      end
    end

    def parent_for(options)
      return reset_wrapper unless options.key?(:wrapper)

      new_options = [options[:wrapper][:element], options[:wrapper].fetch(:attrs, {})]
      return wrapper_element if new_options == wrapper_options

      create_wrapper(new_options)
    end

    def reset_wrapper
      set_wrapper(fragment)
      wrapper_element
    end

    def atomic_block_map
      block_map.fetch('atomic', [])
    end

    def create_wrapper(options)
      document.create_element(*options).tap do |new_element|
        reset_wrapper.add_child(new_element)
        set_wrapper(new_element, options)
      end
    end

    def find_atomic_block_options(block)
      block_data = block.fetch(:data, {})

      block_export = atomic_block_map.find do |block|
        data_to_match = block.fetch(:match_data, {})

        data_to_match.all? do |key, value|
          block_data[key] == value
        end
      end

      return nil if block_export.nil?

      block_export[:options]
    end
  end
end
