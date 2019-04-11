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

    def set_wrapper(element, options = {}, should_nest: false)
      @wrappers[
        should_nest ? @wrappers.length : 0
      ] = [element, options]
    end

    def wrapper_element
      @wrappers.last[0] || fragment
    end

    def wrapper_options
      @wrappers.last[1]
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

      new_options = [options[:wrapper][:element], options[:wrapper].fetch(:attrs, {})]

      create_wrapper(new_options, should_nest: false) if new_options != wrapper_options

      depth = block[:depth]
      level_difference = depth - (@wrappers.length - 1)

      if level_difference > 0
        level_difference.times do 
          create_wrapper(new_options, should_nest: true) 
        end
      else
        @wrappers.pop(-level_difference)
      end   

      wrapper_element
    end

    def reset_wrapper
      clear_wrappers
      set_wrapper(fragment)
      wrapper_element
    end

    def atomic_block_map
      block_map.fetch('atomic', [])
    end

    def create_wrapper(options, should_nest: true)
      document.create_element(*options).tap do |new_element|
        target_wrapper = should_nest ? wrapper_element : reset_wrapper;
        target_wrapper.add_child(new_element)
        set_wrapper(new_element, options, should_nest: should_nest)
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
