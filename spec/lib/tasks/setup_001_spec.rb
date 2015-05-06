require 'rails_helper'
require 'vcr_helper'
require 'tasks/setup_001'

RSpec.describe Setup001, type: :request, version: :v1, speed: :slow, vcr: VCR_OPTS do

  it "doesn't catch on fire" do
    expect(Setup001.call.errors).to be_empty
  end

end
