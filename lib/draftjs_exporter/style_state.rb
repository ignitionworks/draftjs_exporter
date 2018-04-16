# frozen_string_literal: true
module DraftjsExporter
  class StyleState
    attr_reader :styles, :style_map, :unknown_styles

    def initialize(style_map, unknown_styles: :warn)
      @styles = []
      @style_map = style_map
      @unknown_styles = unknown_styles
    end

    def apply(command)
      case command.name
      when :start_inline_style
        styles.push(command.data)
      when :stop_inline_style
        styles.delete(command.data)
      end
    end

    def text?
      styles.empty?
    end

    def element_attributes
      css_attributes = calculate_styles
      if css_attributes.any?
        { style: css_attributes.join }
      else
        {}
      end
    end

    private

    def calculate_styles
      styles.map { |style|
        fetch_style(style)
      }.compact.inject({}, :merge).map { |key, value|
        "#{hyphenize(key)}: #{value};"
      }
    end

    def fetch_style(style)
      style_map.fetch(style) { |style|
        case unknown_styles
        when :warn, :ignore
          warn("Missing definition for style: #{style}") if unknown_styles == :warn
          nil
        else
          raise KeyError, "Cannot find style #{style}"
        end
      }
    end

    def hyphenize(string)
      string.to_s.gsub(/[A-Z]/) { |match| "-#{match.downcase}" }
    end
  end
end
