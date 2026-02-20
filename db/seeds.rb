# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

DEMO_PASSWORD = 'DemoPass123!'.freeze

COMPETENCIES = [
  'Respect and Inclusion',
  'Resilience',
  'Financial Literacy',
  'Ethical Leadership',
  'Technology',
  'Physical and Mental Wellness',
  'Adaptability',
  'Professionalism',
  'Communication',
  'Career and Self Development',
  'Teamwork',
  'Critical Thinking'
].freeze

COMPETENCIES.each do |competency|
  Competency.find_or_create_by(name: competency)
end

def find_or_create_unit(name:, cat:, email: 'no_email', parent: nil)
  unit = Unit.find_or_create_by!(name:, cat:) do |u|
    u.email = email
    u.parent = parent
  end

  unit.update!(email:) if unit.email.blank?
  unit.update!(parent:) if parent && unit.parent_id != parent.id
  unit
end

def upsert_demo_user(username:, email:, first_name:, last_name:, unit:, admin_flag:, unit_name:, major:, minor:)
  user = User.find_or_initialize_by(username:)
  user.assign_attributes(
    email:,
    first_name:,
    last_name:,
    provider: 'local',
    uid: nil,
    unit:,
    unit_name:,
    major:,
    minor:,
    admin_flag:
  )
  user.password = DEMO_PASSWORD
  user.password_confirmation = DEMO_PASSWORD
  user.save!
end

cmdt = find_or_create_unit(name: 'CMDT Staff', cat: 'cmdt')
major = find_or_create_unit(name: 'Unassigned Major', cat: 'major', parent: cmdt)
minor = find_or_create_unit(name: 'Unassigned Minor', cat: 'minor', parent: major)
unassigned_outfit = find_or_create_unit(name: 'Unassigned Outfit', cat: 'outfit', parent: minor)

IngestRosterFile.new.ingest_roster_file('lib/assets/devroster.csv')

submitter_outfit = Unit.find_by(name: 'P2', cat: 'outfit') || unassigned_outfit
minor_unit = Unit.find_by(name: '5BN', cat: 'minor') || submitter_outfit.parent || minor
major_unit = Unit.find_by(name: '1REG', cat: 'major') || minor_unit.parent || major
cmdt_unit = Unit.find_by(name: 'CMDT Staff', cat: 'cmdt') || major_unit.parent || cmdt

upsert_demo_user(
  username: 'demo_admin',
  email: 'demo_admin@local.test',
  first_name: 'Demo',
  last_name: 'Admin',
  unit: unassigned_outfit,
  admin_flag: true,
  unit_name: 'Unassigned Outfit',
  major: 'Unassigned Major',
  minor: 'Unassigned Minor'
)

upsert_demo_user(
  username: 'demo_submitter',
  email: 'demo_submitter@local.test',
  first_name: 'Demo',
  last_name: 'Submitter',
  unit: submitter_outfit,
  admin_flag: false,
  unit_name: submitter_outfit.name,
  major: major_unit.name,
  minor: minor_unit.name
)

upsert_demo_user(
  username: 'demo_minor',
  email: 'demo_minor_staff@local.test',
  first_name: 'Demo',
  last_name: 'Minor Staff',
  unit: minor_unit,
  admin_flag: false,
  unit_name: "#{minor_unit.name} Staff",
  major: major_unit.name,
  minor: minor_unit.name
)

upsert_demo_user(
  username: 'demo_major',
  email: 'demo_major_staff@local.test',
  first_name: 'Demo',
  last_name: 'Major Staff',
  unit: major_unit,
  admin_flag: false,
  unit_name: "#{major_unit.name} Staff",
  major: major_unit.name,
  minor: nil
)

upsert_demo_user(
  username: 'demo_cmdt',
  email: 'demo_cmdt_staff@local.test',
  first_name: 'Demo',
  last_name: 'CMDT Staff',
  unit: cmdt_unit,
  admin_flag: false,
  unit_name: cmdt_unit.name,
  major: nil,
  minor: nil
)
