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
    'header-one' => { element: 'h1', attrs: { id: 'foo-bar' }},
    'unordered-list-item' => {
      element: 'li',
      wrapper: {
        element: 'ul',
        attrs: { class: 'public-DraftStyleDefault-ul' }
      }
    },
    'unstyled' => { element: 'div' },
    # For atomic blocks, we match data to find the right block blocks.
    # Unmatched atomic blocks will use the un-styled block options.
    'atomic' => [
      {
        match_data: {
          type: 'task',
          checked: true,
          title: 'hello'
        },
        options: { element: 'span' }
      }
    ]
  },
  style_map: {
    'ITALIC' => { fontStyle: 'italic' }
  },
  style_block_map: {
    'ITALIC' => 'i',
    'BOLD' => 'b'
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
        },
        {
          offset: 0,
          length: 4,
          style: 'BOLD'
        }
      ],
      entityRanges: [
        {
          offset: 5,
          length: 9,
          key: 0
        }
      ]
    },
    {
      key: '7dhap',
      text: 'hello world',
      type: 'atomic',
      depth: 0,
      inlineStyleRanges: [],
      entityRanges: [],
      data: {
        type: 'task',
        checked: true,
        title: 'hello'
      }
    },
    {
      key: '6usk2',
      text: 'foo bar foo',
      type: 'atomic',
      depth: 0,
      inlineStyleRanges: [],
      entityRanges: [],
      data: {
        type: 'checklist'
      }
    }
  ]
})
# => "<h1 id='foo-bar'>Header</h1><div>\n<i><b><span style=\"font-style: italic;\">some</span></b></i> <a href=\"http://example.com\" class=\"link\">paragraph</a> text</div><span>hello world</span><div>foo bar foo</div>"
```

## Tests

```bash
$ rspec
```
