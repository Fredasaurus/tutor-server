FactoryGirl.define do
  factory :content_tag, class: '::Content::Models::Tag' do
    value { SecureRandom.hex }
    name { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
  end
end
