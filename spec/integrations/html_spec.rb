# frozen_string_literal: true
require 'spec_helper'
require 'draftjs_exporter/html'
require 'draftjs_exporter/entities/link'

RSpec.describe DraftjsExporter::HTML do
  subject(:mapper) do
    described_class.new(
      entity_decorators: {
        'LINK' => DraftjsExporter::Entities::Link.new(className: 'foobar-baz')
      },
      block_map: {
        'header-one' => { element: 'h1' },
        'unordered-list-item' => {
          element: 'li',
          wrapper: {
            element: 'ul',
            attrs: { class: 'public-DraftStyleDefault-ul' }
          }
        },
        'unstyled' => { element: 'div' },
        'atomic' => [
          {
            match_data: {
              type: 'checklist',
              checked: true
            },
            options: {
              element: 'span',
              attrs: { id: 'hello-world' }
            }
          },
          {
            match_data: {
              type: 'story',
              name: 'yvonne'
            },
            options: {
              element: 'article',
              attrs: { title: 'paradise' },
              prefix: '( ) '
            }
          }
        ]
      },
      style_map: {
        'ITALIC' => { fontStyle: 'italic' }
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
              inlineStyleRanges: nil,
              entityRanges: nil
            },
            {
              key: '6udia',
              text: 'Hello my beautiful children',
              type: 'atomic',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [],
              data: {
                type: 'checklist',
                checked: true
              }
            },
            {
              key: '7j1l',
              text: 'Nice to meet me',
              type: 'atomic',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [],
              data: {
                type: 'story',
                name: 'yvonne'
              }
            },
            {
              key: 'jq89x',
              text: 'Wishful thinking',
              type: 'atomic',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [],
              data: { type: 'task' }
            },
          ]
        }

        expected_output = <<-OUTPUT.strip
<h1>Header</h1><div>some paragraph text</div><span id="hello-world">Hello my beautiful children</span><article title="paradise">( ) Nice to meet me</article><div>Wishful thinking</div>
        OUTPUT

        expect(mapper.call(input)).to eq(expected_output)
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
                },
                {
                  offset: 5,
                  length: 5,
                  style: 'BOLD'
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

    context 'with UTF-8 encoding' do
      it 'leaves non-latin letters as-is' do
        input = {
          entityMap: {},
          blocks: [
            {
              key: 'ckf8d',
              text: 'Russian: Привет, мир!',
              type: 'unordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [],
              data: {}
            },
            {
              key: 'fi809',
              text: 'Japanese: 曖昧さ回避',
              type: 'unordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [],
              data: {}
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
          <ul class=\"public-DraftStyleDefault-ul\">\n<li>Russian: Привет, мир!</li>\n<li>Japanese: 曖昧さ回避</li>\n</ul>
        OUTPUT

        expect(mapper.call(input, encoding: 'UTF-8')).to eq(expected_output)
      end
    end
  end
end
