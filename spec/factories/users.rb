# frozen_string_literal: true

FactoryBot.define do
  factory :unit do
    name { 'Dummy Outfit' }
    cat { 'outfit' }
    email { 'dummy_outfit_email@email.email' }
    parent_id { nil }
  end

  factory :user do
    email { "user#{SecureRandom.random_number(1_000_000)}@tamu.edu" }
    first_name { "Test#{SecureRandom.hex(4)}" }
    last_name { 'User' }
    uid { SecureRandom.random_number(1_000_000_000).to_s }
    provider { 'google_oauth2' }
    unit_id { FactoryBot.create(:unit).id }
    admin_flag { true }

    trait :local_auth do
      provider { 'local' }
      uid { nil }
      username { "demo_#{SecureRandom.hex(4)}" }
      password { 'DemoPass123!' }
      password_confirmation { 'DemoPass123!' }
    end
  end
end
