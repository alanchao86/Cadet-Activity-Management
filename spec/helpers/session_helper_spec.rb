# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionHelper do
  subject(:session_helper) { helper_class.new }

  let(:helper_class) do
    Class.new do
      include SessionHelper
    end
  end

  let(:unassigned_outfit) { Unit.find_by(name: 'Unassigned Outfit') }

  describe '#create_new_user' do
    it 'creates a user even when Google provides a single-word name' do
      auth = {
        'provider' => 'google_oauth2',
        'uid' => 'single-name-user-uid',
        'info' => {
          'email' => 'singleword@tamu.edu',
          'name' => 'Prince'
        }
      }

      user = session_helper.create_new_user(auth)

      expect(user).to be_persisted
      expect(user.first_name).to eq('Prince')
      expect(user.last_name).to eq('N/A')
      expect(user.unit).to eq(unassigned_outfit)
    end
  end

  describe '#check_preloaded_database' do
    it 'persists uid/provider for a preloaded user' do
      user = User.create!(
        email: 'preloaded@tamu.edu',
        first_name: 'Pre',
        last_name: 'Loaded',
        uid: nil,
        provider: 'preloaded_google',
        unit: unassigned_outfit,
        admin_flag: false
      )

      auth = {
        'provider' => 'google_oauth2',
        'uid' => 'new-google-uid',
        'info' => {
          'email' => 'preloaded@tamu.edu'
        }
      }

      updated_user = session_helper.check_preloaded_database(auth)

      expect(updated_user.uid).to eq('new-google-uid')
      expect(updated_user.provider).to eq('google_oauth2')
      expect(User.find(user.id).uid).to eq('new-google-uid')
    end
  end
end
