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
      styles.empty?
    end

    def element_attributes
      return {} unless styles.any?
      { style: styles_css }
    end

    def element_attributes_for(style)
      return {} unless styles.any?
      result = [fetch_or_default_style(style)].inject({}, :merge).delete_if { |key, _| key == :element }.map { |key, value|
        "#{hyphenize(key)}: #{value};"
      }.join
      { style: result }
    end

    def styles_css
      styles.map { |style|
        fetch_or_default_style(style)
      }.inject({}, :merge).map { |key, value|
        "#{hyphenize(key)}: #{value};"
      }.join
    end

    def hyphenize(string)
      string.to_s.gsub(/[A-Z]/) { |match| "-#{match.downcase}" }
    end

    def fetch_or_default_style(type)
      if !style_map.fetch(type, nil).nil?
        style_map.fetch(type)
      elsif !style_map.fetch('default', nil).nil?
        style_map.fetch('default')
      else
        style_map.fetch(type) # Raise exception to be backward compatible
      end
    end
  end
end
