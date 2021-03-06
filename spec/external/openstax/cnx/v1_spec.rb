require 'rails_helper'
require 'vcr_helper'

RSpec.describe OpenStax::Cnx::V1, :type => :external, :vcr => VCR_OPTS do
  let!(:cnx_collection_id) { '93e2b09d-261c-4007-a987-0b3062fe154b' }
  let!(:cnx_module_id)     { '95e61258-2faf-41d4-af92-f62e1414175a' }

  it "can generate url's for resources in the cnx archive" do
    expect(OpenStax::Cnx::V1.url_for('module_id@version')).to(
      eq('https://archive-staging-tutor.cnx.org/contents/module_id@version'))

    expect(OpenStax::Cnx::V1.url_for('/resources/image.jpg')).to(
      eq('https://archive-staging-tutor.cnx.org/resources/image.jpg'))
  end

  it "can fetch collections and modules from CNX" do
    collection_hash = OpenStax::Cnx::V1.fetch(cnx_collection_id)
    module_hash = OpenStax::Cnx::V1.fetch(cnx_module_id)

    expect(collection_hash).to be_a Hash
    expect(collection_hash).not_to be_empty

    expect(module_hash).to be_a Hash
    expect(module_hash).not_to be_empty
  end

  it "can instantiate a Book from an id" do
    book = OpenStax::Cnx::V1.book(id: cnx_collection_id)

    expect(book).to be_a OpenStax::Cnx::V1::Book
  end
end
