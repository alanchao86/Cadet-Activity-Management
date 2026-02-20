# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:unit) { create(:unit, name: "Unit#{SecureRandom.hex(3)}", cat: 'outfit') }

  it 'requires username/password for local users' do
    user = build(:user, provider: 'local', uid: nil, username: nil, password: nil, password_confirmation: nil, unit:)

    expect(user).not_to be_valid
    expect(user.errors[:username]).to include("can't be blank")
    expect(user.errors[:password]).to include("can't be blank")
  end

  it 'requires uid for google users' do
    user = build(:user, provider: 'google_oauth2', uid: nil, unit:)

    expect(user).not_to be_valid
    expect(user.errors[:uid]).to include("can't be blank")
  end

  it 'authenticates local users with has_secure_password' do
    user = create(:user, :local_auth, username: 'demo_login', unit:, admin_flag: false)

    expect(user.authenticate('DemoPass123!')).to eq(user)
    expect(user.authenticate('bad-pass')).to be_falsey
  end
end
