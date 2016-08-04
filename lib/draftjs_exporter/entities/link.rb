# frozen_string_literal: true
module DraftjsExporter
  module Entities
    class Link
      attr_reader :configuration

      def initialize(configuration = { className: nil })
        @configuration = configuration
      end

      def call(parent_element, data)
        args = { href: data.fetch(:data, {}).fetch(:url) }
        args[:class] = configuration.fetch(:className) if configuration[:className]

        element = parent_element.document.create_element('a', args)
        parent_element.add_child(element)
        element
      end
    end
  end
end
