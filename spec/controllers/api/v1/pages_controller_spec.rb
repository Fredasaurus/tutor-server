require 'rails_helper'
require 'vcr_helper'

RSpec.describe Api::V1::PagesController, type: :controller, api: true,
                                         version: :v1, speed: :slow, vcr: VCR_OPTS do

  context 'with book' do
    before(:all) do
      DatabaseCleaner.start

      VCR.use_cassette("Api_V1_PagesController/with_book", VCR_OPTS) do
        @book = FetchAndImportBook[id: '93e2b09d-261c-4007-a987-0b3062fe154b']
      end

      @page_uuid = '95e61258-2faf-41d4-af92-f62e1414175a'
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    it 'returns not found if the version is not found' do
      api_get :get_page, nil, parameters: { uuid: @page_uuid,
                                            version: '100' }
      expect(response).to have_http_status(404)
    end

    it 'returns not found if the uuid is not found' do
      api_get :get_page, nil, parameters: { uuid: 'b5cd5a64-34a1-434e-b8ba-769000fbec30',
                                            version: '1' }
      expect(response).to have_http_status(404)
    end

    it 'returns not found if the version is not a number' do
      api_get :get_page, nil, parameters: { uuid: @page_uuid,
                                            version: 'x' }
      expect(response).to have_http_status(404)
    end

    context 'with an old version of force' do
      before(:all) do
        page_hash = { id: "#{@page_uuid}@2", title: 'Force' }

        book_part = FactoryGirl.create :content_book_part
        cnx_page = OpenStax::Cnx::V1::Page.new(page_hash)
        VCR.use_cassette("Api_V1_PagesController/with_an_old_version_of_force", VCR_OPTS) do
          @old_page = Content::Routines::ImportPage.call(cnx_page: cnx_page,
                                                         book_part: book_part).outputs[:page]
        end
      end

      it 'returns the page with the correct uuid and version' do
        api_get :get_page, nil, parameters: { uuid: @page_uuid,
                                              version: '2' }
        expect(response).to have_http_status(200)
        expect(response.body_as_hash).to eq({
          content_html: @old_page.content
        })
      end

      it 'returns the page with the correct uuid and latest version if version is empty' do
        api_get :get_page, nil, parameters: { uuid: @page_uuid }
        page = Content::Models::Page.where(uuid: @page_uuid).order(version: :desc).first
        expect(response).to have_http_status(200)
        expect(response.body_as_hash).to eq({
          content_html: page.content
        })
      end
    end
  end

end
