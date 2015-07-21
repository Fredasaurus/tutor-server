require 'rails_helper'

RSpec.describe Content::VisitBookPart, :type => :routine do

  around(:each) do |example|
    OpenStax::Exercises::V1.fake_client.reset!
    OpenStax::Exercises::V1.with_fake_client { example.run }
    OpenStax::Exercises::V1.fake_client.reset!
  end

  let!(:book_part) {
    FactoryGirl.create(:content_book_part, :standard_contents_1)
  }

  it "should get the TOC with the TOC option" do

    toc = Content::VisitBookPart[book_part: book_part, visitor_names: :toc]
    expect(toc).to eq({
      'id' => toc.id,
      'title' => 'book title',
      'type' => 'part',
      'chapter_section' => [],
      'children' => [
        'id' => toc.children[0].id,
        'title' => 'unit 1',
        'type' => 'part',
        'chapter_section' => [1],
        'children' => [
          {
            'id' => toc.children[0].children[0].id,
            'title' => 'chapter 1',
            'type' => 'part',
            'chapter_section' => [1, 1],
            'children' => [
              {
                'id' => toc.children[0].children[0].children[0].id,
                'cnx_id' => Content::Models::Page.find(toc.children[0].children[0].children[0].id).cnx_id,
                'title' => 'first page',
                'type' => 'page',
                'chapter_section' => [1, 1, 1]
              },
              {
                'id' => toc.children[0].children[0].children[1].id,
                'cnx_id' => Content::Models::Page.find(toc.children[0].children[0].children[1].id).cnx_id,
                'title' => 'second page',
                'type' => 'page',
                'chapter_section' => [1, 1, 2]
              }
            ]
          },
          {
            'id' => toc.children[0].children[1].id,
            'title' => 'chapter 2',
            'type' => 'part',
            'chapter_section' => [1, 2],
            'children' => [
              {
                'id' => toc.children[0].children[1].children[0].id,
                'cnx_id' => Content::Models::Page.find(toc.children[0].children[1].children[0].id).cnx_id,
                'title' => 'third page',
                'type' => 'page',
                'chapter_section' => [1, 2, 1]
              }
            ]
          }
        ]
      ]
    })
  end

  it "should get tagged exercises out of a book_part" do

    OpenStax::Exercises::V1.fake_client.add_exercise(tags: ['ost-tag-lo-topic1-lo1', 'concept'])
    OpenStax::Exercises::V1.fake_client.add_exercise(tags: ['ost-tag-lo-topic2-lo2', 'homework'])
    OpenStax::Exercises::V1.fake_client.add_exercise(tags: ['ost-tag-lo-topic3-lo3', 'concept'])

    Content::Routines::ImportExercises.call(tag: 'ost-tag-lo-topic1-lo1')
    Content::Routines::ImportExercises.call(tag: 'ost-tag-lo-topic2-lo2')
    Content::Routines::ImportExercises.call(tag: 'ost-tag-lo-topic3-lo3')

    exercises = Content::VisitBookPart[book_part: book_part, visitor_names: :exercises]

    expect(exercises).to include({
      '-1@1' => {
        'uid' => '-1@1',
        'id' => exercises['-1@1']['id'],
        'url' => a_kind_of(String),
        'los' => ['ost-tag-lo-topic1-lo1'],
        'tags' => ['concept']
      },
      '-2@1' => {
        'uid' => '-2@1',
        'id' => exercises['-2@1']['id'],
        'url' => a_kind_of(String),
        'los' => ['ost-tag-lo-topic2-lo2'],
        'tags' => ['homework']
      },
      '-3@1' => {
        'uid' => '-3@1',
        'id' => exercises['-3@1']['id'],
        'url' => a_kind_of(String),
        'los' => ['ost-tag-lo-topic3-lo3'],
        'tags' => ['concept']
      }
    })

  end

  it "should cache visitations" do
    trials = [
      { name: :toc,       attribute: :toc_cache,       fake_data: {'fake' => 'hash'} },
      { name: :page_data, attribute: :page_data_cache, fake_data: ['fake', 'array']}
    ]


    trials.each do |trial|
      Content::VisitBookPart[book_part: book_part, visitor_names: trial[:name]]
      book_part.reload

      expect(book_part.send(trial[:attribute])).not_to be_blank

      book_part.update_attribute(trial[:attribute], trial[:fake_data])

      value = Content::VisitBookPart[book_part: book_part, visitor_names: trial[:name]]
      expect(value).to eq(trial[:fake_data])
    end
  end

end
