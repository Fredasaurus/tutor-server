require 'rails_helper'
require 'vcr_helper'
require 'tasks/demo_001'

RSpec.describe Demo001, type: :request, version: :v1, speed: :slow, vcr: VCR_OPTS do

  it "doesn't catch on fire" do
    expect(Demo001.call(print_logs: false).errors).to be_empty
  end

end