require 'rails_helper'

RSpec.describe OpenStax::Biglearn::V1, :type => :external do
  it 'can be configured' do
    configuration = OpenStax::Biglearn::V1.configuration
    expect(configuration).to be_a(OpenStax::Biglearn::V1::Configuration)

    OpenStax::Biglearn::V1.configure do |config|
      expect(config).to eq configuration
    end
  end

  it 'can use the fake client or the real client' do
    initial_client = OpenStax::Biglearn::V1.send :client

    OpenStax::Biglearn::V1.use_fake_client
    expect(OpenStax::Biglearn::V1.send :client).to be_a(OpenStax::Biglearn::V1::FakeClient)

    OpenStax::Biglearn::V1.use_real_client
    expect(OpenStax::Biglearn::V1.send :client).to be_a(OpenStax::Biglearn::V1::RealClient)

    OpenStax::Biglearn::V1.use_fake_client
    expect(OpenStax::Biglearn::V1.send :client).to be_a(OpenStax::Biglearn::V1::FakeClient)

    OpenStax::Biglearn::V1.instance_variable_set('@client', initial_client)
  end

  context 'api calls' do
    let!(:client)   { OpenStax::Biglearn::V1.send :client }
    let!(:role)     { Entity::Role.create! }
    let!(:tag)      { 'test-tag' }
    let!(:exercise) { OpenStax::Biglearn::V1::Exercise.new('e42', 'topic') }

    it 'delegates get_clue to the client' do
      expect(client).to receive(:get_clue).twice.with(roles: [role], tags: [tag])
      expect(OpenStax::Biglearn::V1.get_clue(roles: [role], tags: [tag])).to(
        eq client.get_clue(roles: [role], tags: [tag])
      )
    end

    it 'delegates add_exercises to the client' do
      expect(client).to receive(:add_exercises).twice.with(exercises: [exercise])
      expect(OpenStax::Biglearn::V1.add_exercises(exercises: [exercise])).to(
        eq client.add_exercises(exercises: [exercise])
      )
    end

    it 'delegates get_projection_exercises to the client' do
      expect(client).to receive(:get_projection_exercises).twice.with(
        role: role, tag_search: tag, count: 2, difficulty: 0.6, allow_repetitions: false
      )
      expect(OpenStax::Biglearn::V1.get_projection_exercises(
        role: role, tag_search: tag, count: 2, difficulty: 0.6, allow_repetitions: false
      )).to eq client.get_projection_exercises(
        role: role, tag_search: tag, count: 2, difficulty: 0.6, allow_repetitions: false
      )
    end
  end
end
