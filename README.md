# Draft.js Exporter

[![Circle CI](https://circleci.com/gh/ignitionworks/draftjs_exporter/tree/master.svg?style=shield)](https://circleci.com/gh/ignitionworks/draftjs_exporter/tree/master)
[![Code Climate](https://codeclimate.com/github/ignitionworks/draftjs_exporter/badges/gpa.svg)](https://codeclimate.com/github/ignitionworks/draftjs_exporter)
[![Test Coverage](https://codeclimate.com/github/ignitionworks/draftjs_exporter/badges/coverage.svg)](https://codeclimate.com/github/ignitionworks/draftjs_exporter/coverage)

[Draft.js](https://facebook.github.io/draft-js/) is a framework for
building rich text editors. However, it does not support exporting
documents at HTML. This gem is designed to take the raw `ContentState`
(output of [`convertToRaw`](https://facebook.github.io/draft-js/docs/api-reference-data-conversion.html#converttoraw))
from Draft.js and convert it to HTML using Ruby.

## Usage

```ruby
# Create configuration for entities and styles
config = {
  entity_decorators: {
    'LINK' => DraftjsExporter::Entities::Link.new(className: 'link')
  },
  block_map: {
    'header-one' => { element: 'h1' },
    'unordered-list-item' => {
      element: 'li',
      wrapper: ['ul', { className: 'public-DraftStyleDefault-ul' }]
    },
    'unstyled' => { element: 'div' }
  },
  style_map: {
    'ITALIC' => { fontStyle: 'italic' }
  }
}

# New up the exporter
exporter = DraftjsExporter::HTML.new(config)

# Provide raw content state
exporter.call({
  entityMap: {
    '0' => {
      type: 'LINK',
      mutability: 'MUTABLE',
      data: {
        url: 'http://example.com'
      }
    }
  },
  blocks: [
    {
      key: '5s7g9',
      text: 'Header',
      type: 'header-one',
      depth: 0,
      inlineStyleRanges: [],
      entityRanges: []
    },
    {
      key: 'dem5p',
      text: 'some paragraph text',
      type: 'unstyled',
      depth: 0,
      inlineStyleRanges: [
        {
          offset: 0,
          length: 4,
          style: 'ITALIC'
        }
      ],
      entityRanges: [
        {
          offset: 5,
          length: 9,
          key: 0
        }
      ]
    }
  ]
})
# => "<h1>Header</h1><div>\n<span style=\"font-style: italic;\">some</span> <a href=\"http://example.com\" class=\"link\">paragraph</a> text</div>"
```

### Default values
Use config specified in `default` keys if it finds unknown entity_decorators, block_map or style_map
```ruby
config = {
  entity_decorators: {
    'default' => DraftjsExporter::Entities::Link.new(className: 'link')
  },
  block_map: {
    'default' => { element: 'h1' },
  },
  style_map: {
    'default' => { fontStyle: 'default' }
  }
}

exporter = DraftjsExporter::HTML.new(config)

exporter.call({
  entityMap: {
    '0' => {
      type: 'LINK',
      mutability: 'MUTABLE',
      data: {
        url: 'http://example.com'
      }
    }
  },
  blocks: [
    {
      key: '5s7g9',
      text: 'Header',
      type: 'header-one',
      depth: 0,
      inlineStyleRanges: [],
      entityRanges: []
    },
    {
      key: 'dem5p',
      text: 'some paragraph text',
      type: 'unstyled',
      depth: 0,
      inlineStyleRanges: [
        {
          offset: 0,
          length: 4,
          style: 'ITALIC'
        }
      ],
      entityRanges: [
        {
          offset: 5,
          length: 9,
          key: 0
        }
      ]
    }
  ]
})
# => "<h1>Header</h1><div>\n<span style=\"font-style: default;\">some</span> <a href=\"http://example.com\" class=\"link\">paragraph</a> text</div>"
```
To see messages about missing properties when 'default' properties are used, define logger: 

`DraftjsExporter.logger = Logger.new(STDOUT)`

### Specify custom element for style, different to span
```ruby
config = {
  entity_decorators: {
    'LINK' => DraftjsExporter::Entities::Link.new(className: 'link')
  },
  block_map: {
    'header-one' => { element: 'h1' },
    'unordered-list-item' => {
      element: 'li',
      wrapper: ['ul', { className: 'public-DraftStyleDefault-ul' }]
    },
    'unstyled' => { element: 'div' }
  },
  style_map: {
    'ITALIC' => { fontStyle: 'italic', element: 'i' }
  }
}

exporter = DraftjsExporter::HTML.new(config)

exporter.call({
  entityMap: {
    '0' => {
      type: 'LINK',
      mutability: 'MUTABLE',
      data: {
        url: 'http://example.com'
      }
    }
  },
  blocks: [
    {
      key: '5s7g9',
      text: 'Header',
      type: 'header-one',
      depth: 0,
      inlineStyleRanges: [],
      entityRanges: []
    },
    {
      key: 'dem5p',
      text: 'some paragraph text',
      type: 'unstyled',
      depth: 0,
      inlineStyleRanges: [
        {
          offset: 0,
          length: 4,
          style: 'ITALIC'
        }
      ],
      entityRanges: [
        {
          offset: 5,
          length: 9,
          key: 0
        }
      ]
    }
  ]
})
# => "<h1>Header</h1><div>\n<i style=\"font-style: italic;\">some</i> <a href=\"http://example.com\" class=\"link\">paragraph</a> text</div>"
```

## Tests

```bash
$ rspec
```

