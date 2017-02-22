# frozen_string_literal: true
require 'spec_helper'
require 'draftjs_exporter/html'
require 'draftjs_exporter/entities/link'

RSpec.describe DraftjsExporter::HTML do
  subject(:mapper) do
    described_class.new(
      entity_decorators: {
        'LINK' => DraftjsExporter::Entities::Link.new(className: 'foobar-baz'),
      },
      block_map: {
        'header-one' => { element: 'h1' },
        'unordered-list-item' => {
          element: 'li',
          wrapper: ['ul', { className: 'public-DraftStyleDefault-ul' }]
        },
        'unstyled' => { element: 'div' },
      },
      style_map: {
        'ITALIC' => { fontStyle: 'italic' },
        'BOLD' => { fontStyle: 'bold' },
        'UNDERLINE' => { fontStyle: 'underline' },
      }
    )
  end

  subject(:mapper_with_defaults) do
    described_class.new(
      entity_decorators: {
        'LINK' => DraftjsExporter::Entities::Link.new(className: 'foobar-baz'),
        'default' => DraftjsExporter::Entities::Null.new
      },
      block_map: {
        'header-one' => { element: 'h1' },
        'unordered-list-item' => {
          element: 'li',
          wrapper: ['ul', { className: 'public-DraftStyleDefault-ul' }]
        },
        'unstyled' => { element: 'div' },
        'default' => { element: 'p' }
      },
      style_map: {
        'ITALIC' => { fontStyle: 'italic' },
        'BOLD' => { fontStyle: 'bold' },
        'UNDERLINE' => { fontStyle: 'underline' },
        'default' => {}
      }
    )
  end

  describe '#call' do
    context 'with different blocks' do
      it 'decodes the content_state to html' do
        input = {
          entityMap: {},
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
              inlineStyleRanges: [],
              entityRanges: []
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
<h1>Header</h1><div>some paragraph text</div>
        OUTPUT

        expect(mapper.call(input)).to eq(expected_output)
      end

      it 'throws an exception if it has not specified style' do
        input = {
          entityMap: {},
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
              type: 'not-specified',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            }
          ]
        }

        expect{mapper.call(input)}.to raise_error(KeyError)
      end

      it 'decodes the content_state to html with not specified block as default block' do
        input = {
          entityMap: {},
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
              type: 'not-specified',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
<h1>Header</h1><p>some paragraph text</p>
        OUTPUT

        expect(mapper_with_defaults.call(input)).to eq(expected_output)
      end

    end

    context 'with inline styles' do
      it 'decodes the content_state to html' do
        input = {
          entityMap: {},
          blocks: [
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
              entityRanges: []
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
<div>
<span style="font-style: italic;">some</span> paragraph text</div>
        OUTPUT

        expect(mapper.call(input)).to eq(expected_output)
      end

      it 'decodes the content_state to html with cross over styles' do
        input = {
          "entityMap": {},
          "blocks": [
            {
              "key": "d9imo",
              "text": "bold underline italic",
              "type": "unstyled",
              "depth": 0,
              "inlineStyleRanges": [
                {
                  "offset": 0,
                  "length": 21,
                  "style": "BOLD"
                },
                {
                  "offset": 0,
                  "length": 21,
                  "style": "ITALIC"
                },
                {
                  "offset": 0,
                  "length": 21,
                  "style": "UNDERLINE"
                }
              ],
              "entityRanges": [],
              "data": {}
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
<div>
<span style="font-style: bold;"><span style="font-style: italic;"><span style="font-style: underline;">bold underline italic</span></span></span></div>
        OUTPUT
        expect(mapper.call(input)).to eq(expected_output)
      end

      it 'throws an exception if it has not specified style' do
        input = {
          "entityMap": {},
          "blocks": [
            {
              "key": "8i08p",
              "text": "some text",
              "type": "unstyled",
              "depth": 0,
              "inlineStyleRanges": [
                {
                  "offset": 0,
                  "length": 9,
                  "style": "not-specified"
                }
              ],
              "entityRanges": [],
              "data": {}
            }
          ]
        }

        expect{mapper.call(input)}.to raise_error(KeyError)
      end

      it 'decodes the content_state to html with not specified styles as default styles' do
        input = {
          "entityMap": {},
          "blocks": [
            {
              "key": "8i08p",
              "text": "some text",
              "type": "unstyled",
              "depth": 0,
              "inlineStyleRanges": [
                {
                  "offset": 0,
                  "length": 9,
                  "style": "not-specified"
                }
              ],
              "entityRanges": [],
              "data": {}
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
<div>
<span style="">some text</span></div>
        OUTPUT
        expect(mapper_with_defaults.call(input)).to eq(expected_output)
      end

    end

    context 'with entities' do
      it 'decodes the content_state to html' do
        input = {
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
              key: 'dem5p',
              text: 'some paragraph text',
              type: 'unstyled',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [
                {
                  offset: 5,
                  length: 9,
                  key: 0
                }
              ]
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
<div>some <a href="http://example.com" class="foobar-baz">paragraph</a> text</div>
        OUTPUT

        expect(mapper.call(input)).to eq(expected_output)
      end

      context 'with deeply_symbolized entities' do
        it 'decodes the content_state to html' do
          input = {
            entityMap: {
              :'0' => {
                type: 'LINK',
                mutability: 'MUTABLE',
                data: {
                  url: 'http://example.com'
                }
              }
            },
            blocks: [
              {
                key: 'dem5p',
                text: 'some paragraph text',
                type: 'unstyled',
                depth: 0,
                inlineStyleRanges: [],
                entityRanges: [
                  {
                    offset: 5,
                    length: 9,
                    key: 0
                  }
                ]
              }
            ]
          }

          expected_output = <<-OUTPUT.strip
<div>some <a href="http://example.com" class="foobar-baz">paragraph</a> text</div>
          OUTPUT

          expect(mapper.call(input)).to eq(expected_output)
        end
      end


      it 'throws an error if entities cross over' do
        input = {
          entityMap: {
            '0' => {
              type: 'LINK',
              mutability: 'MUTABLE',
              data: {
                url: 'http://foo.example.com'
              }
            },
            '1' => {
              type: 'LINK',
              mutability: 'MUTABLE',
              data: {
                url: 'http://bar.example.com'
              }
            }
          },
          blocks: [
            {
              key: 'dem5p',
              text: 'some paragraph text',
              type: 'unstyled',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [
                {
                  offset: 5,
                  length: 9,
                  key: 0
                },
                {
                  offset: 2,
                  length: 9,
                  key: 1
                }
              ]
            }
          ]
        }

        expect { mapper.call(input) }.to raise_error(DraftjsExporter::InvalidEntity)
      end

      it 'throws an exception if it has not specified entity' do
        input = {
          entityMap: {
            '0' => {
              type: 'not-specified',
              mutability: 'MUTABLE',
              data: {
                url: 'http://example.com'
              }
            }
          },
          blocks: [
            {
              key: 'dem5p',
              text: 'some paragraph text',
              type: 'unstyled',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [
                {
                  offset: 5,
                  length: 9,
                  key: 0
                }
              ]
            }
          ]
        }

        expect{mapper.call(input)}.to raise_error(KeyError)
      end

      it 'decodes the content_state to html with not specified entity as default entity' do
        input = {
          entityMap: {
            '0' => {
              type: 'not-specified',
              mutability: 'MUTABLE',
              data: {
                url: 'http://example.com'
              }
            }
          },
          blocks: [
            {
              key: 'dem5p',
              text: 'some paragraph text',
              type: 'unstyled',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [
                {
                  offset: 5,
                  length: 9,
                  key: 0
                }
              ]
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
<div>some paragraph text</div>
        OUTPUT

        expect(mapper_with_defaults.call(input)).to eq(expected_output)
      end
    end

    context 'with wrapped blocks' do
      it 'decodes the content_state to html' do
        input = {
          entityMap: {},
          blocks: [
            {
              key: 'dem5p',
              text: 'item1',
              type: 'unordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem5p',
              text: 'item2',
              type: 'unordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
<ul class="public-DraftStyleDefault-ul">\n<li>item1</li>\n<li>item2</li>\n</ul>
        OUTPUT

        expect(mapper.call(input)).to eq(expected_output)
      end
    end
  end
end
