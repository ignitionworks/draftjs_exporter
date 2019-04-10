require 'byebug'

module DraftjsExporter
  class WrapperState
    def initialize(block_map)
      @block_map = block_map
      @document = Nokogiri::HTML::Document.new
      @document.encoding = 'UTF-8' # To not transform HTML entities
      @fragment = Nokogiri::HTML::DocumentFragment.new(document)
      @wrappers = []
      reset_wrapper
    end

    def element_for(block)
      type = block.fetch(:type, 'unstyled')
      unstyled_options = block_map['unstyled']

      return create_element(block, block_map.fetch(type, unstyled_options)) if type != 'atomic'

      atomic_block_options = find_atomic_block_options(block)

      return create_element(block, unstyled_options) if atomic_block_options.nil?

      create_element(block, atomic_block_options)
    end

    def to_s
      to_html
    end

    def to_html(options = {})
      fragment.to_html(options)
    end

    private

    attr_reader :fragment, :document, :block_map, :wrapper

    def clear_wrappers
      @wrappers = []
    end

    def set_wrapper(element, options = {}, depth = 0)
      @wrappers[depth] = [element, options]
    end

    def wrapper_element(wrapper_index = nil)
      return (@wrappers.last[0] || fragment) if wrapper_index.nil?
      @wrappers[wrapper_index][0]
    end

    def wrapper_options(wrapper_index = nil)
      return @wrappers.last[1] if wrapper_index.nil?
      @wrappers[wrapper_index][1]
    end

    def create_element(block, block_options)
      document.create_element(
        block_options[:element],
        block_options.fetch(:prefix, ''),
        block_options.fetch(:attrs, {})
      ).tap do |e|
        parent_for(block, block_options).add_child(e)
      end
    end

    def parent_for(block, options)
      return reset_wrapper unless options.key?(:wrapper)

      depth = block[:depth]
      new_options = [options[:wrapper][:element], options[:wrapper].fetch(:attrs, {})]
      should_reset = new_options != wrapper_options
      should_create_nest = depth > 0 && depth >= @wrappers.length

      if should_reset || should_create_nest
        return create_wrapper(
          new_options,
          should_reset: should_reset,
          depth: depth
        ) 
      end

      wrapper_element(depth)
    end

    def reset_wrapper
      clear_wrappers
      set_wrapper(fragment)
      wrapper_element
    end

    def atomic_block_map
      block_map.fetch('atomic', [])
    end

    def create_wrapper(options, should_reset: true, depth: 0)
      document.create_element(*options).tap do |new_element|
        target_wrapper = should_reset ? reset_wrapper : wrapper_element(depth - 1)
        target_wrapper.add_child(new_element)
        set_wrapper(
          new_element, 
          options, 
          should_reset ? 0 : depth
        )
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
