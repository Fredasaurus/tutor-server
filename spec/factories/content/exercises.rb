FactoryGirl.define do
  factory :content_exercise, class: '::Content::Models::Exercise' do
    url { Faker::Internet.url }
    title { Faker::Lorem.words(3).join(' ') }
  end
end
