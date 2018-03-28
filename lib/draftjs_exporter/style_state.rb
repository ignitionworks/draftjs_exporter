# frozen_string_literal: true
module DraftjsExporter
  class StyleState
    attr_reader :styles, :style_map

    def initialize(style_map)
      @styles = []
      @style_map = style_map
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
      supported_styles.empty?
    end

    def element_attributes
      return {} unless supported_styles.any?
      { style: styles_css }
    end

    def styles_css
      supported_styles
        .map { |style| style_map.fetch(style) }
        .inject({}, :merge).map { |key, value|
          "#{hyphenize(key)}: #{value};"
        }.join
    end

    def supported_styles
      styles.select { |style| !style_map[style].nil? }
    end

    def hyphenize(string)
      string.to_s.gsub(/[A-Z]/) { |match| "-#{match.downcase}" }
    end
  end
end
