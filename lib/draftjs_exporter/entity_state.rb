# frozen_string_literal: true
require 'draftjs_exporter/entities/null'
require 'draftjs_exporter/entities/link'
require 'draftjs_exporter/error'

module DraftjsExporter
  class InvalidEntity < DraftjsExporter::Error; end

  class EntityState
    extend DefaultItem
    has_default_item_in(:entity_decorators)

    attr_reader :entity_decorators, :entity_map, :entity_stack, :root_element

    def initialize(root_element, entity_decorators, entity_map)
      @entity_decorators = entity_decorators
      @entity_map = entity_map
      @entity_stack = [[Entities::Null.new.call(root_element, nil), nil]]
    end

    def apply(command)
      case command.name
      when :start_entity
        start_command(command)
      when :stop_entity
        stop_command(command)
      end
    end

    def current_parent
      element, _data = entity_stack.last
      element
    end

    private

    def start_command(command)
      entity_details = entity_for(command.data)

      decorator = fetch_or_default_item(entity_details.fetch(:type))
      parent_element = entity_stack.last.first
      new_element = decorator.call(parent_element, entity_details)
      entity_stack.push([new_element, entity_details])
    end

    def stop_command(command)
      entity_details = entity_for(command.data)
      _element, expected_entity_details = entity_stack.last

      if expected_entity_details != entity_details
        raise InvalidEntity, "Expected #{expected_entity_details.inspect} got #{entity_details.inspect}"
      end

      entity_stack.pop
    end

    def entity_for(key)
      entity_keys = [key.to_s, key.to_s.to_sym]
      entity_keys.map { |key| entity_map.fetch(key, nil) }.compact.first
    end
  end
end
