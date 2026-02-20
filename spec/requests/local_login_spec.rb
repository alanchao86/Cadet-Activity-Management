# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Local Login', type: :request do
  let(:unit) { Unit.find_or_create_by!(name: 'Unassigned Outfit', cat: 'outfit') { |u| u.email = 'no_email' } }
  let(:local_user) do
    User.find_or_initialize_by(username: 'spec_submitter').tap do |user|
      user.assign_attributes(
        email: 'demo_submitter_spec@local.test',
        first_name: 'Demo',
        last_name: 'Submitter',
        provider: 'local',
        uid: nil,
        unit:,
        admin_flag: false
      )
      user.password = 'DemoPass123!'
      user.password_confirmation = 'DemoPass123!'
      user.save!
    end
  end

  before do
    local_user
  end

  it 'logs in successfully with correct username/password' do
    allow_any_instance_of(ApplicationController).to receive(:local_auth_enabled?).and_return(true)

    post login_path, params: { username: 'spec_submitter', password: 'DemoPass123!' }

    expect(response).to redirect_to(user_path(local_user))
  end

  it 'rejects login with incorrect password' do
    allow_any_instance_of(ApplicationController).to receive(:local_auth_enabled?).and_return(true)

    post login_path, params: { username: 'spec_submitter', password: 'bad-pass' }

    expect(response).to redirect_to(home_path)
    expect(flash[:alert]).to eq('Invalid username or password.')
  end

  it 'rejects login when local auth is disabled' do
    allow_any_instance_of(ApplicationController).to receive(:local_auth_enabled?).and_return(false)

    post login_path, params: { username: 'spec_submitter', password: 'DemoPass123!' }

    expect(response).to redirect_to(home_path)
    expect(flash[:alert]).to eq('Local login is disabled.')
  end
end
