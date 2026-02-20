# frozen_string_literal: true

Given('I am a user with name {string}') do |name|
  name_parts = name.split
  first_name = name_parts.first
  last_name = name_parts[1..].join(' ') # Joins the rest of the parts as the last name.
  email = "#{first_name.downcase}#{last_name.downcase}@tamu.edu"

  cmdt = Unit.create!(name: 'Demo CMDT', cat: 'cmdt')
  major = Unit.create!(name: 'Demo Major', cat: 'major', parent: cmdt)
  minor = Unit.create!(name: 'Demo Minor', cat: 'minor', parent: major)
  outfit = Unit.create!(name: 'Demo Outfit', cat: 'outfit', parent: minor)

  # Create Staff for the minor, major and cmdt units
  User.find_or_create_by(email: 'dummy_minor_unit_staff@tamu.edu') do |minor_unit_staff|
    minor_unit_staff.first_name = 'Demo Minor',
                                  minor_unit_staff.last_name = 'Staff',
                                  minor_unit_staff.provider = 'preloaded_google',
                                  minor_unit_staff.unit = minor,
                                  minor_unit_staff.minor = 'Demo Minor',
                                  minor_unit_staff.major = 'Demo Major',
                                  minor_unit_staff.unit_name = 'Demo Minor Staff',
                                  minor_unit_staff.admin_flag = false
  end

  User.find_or_create_by(email: 'dummy_major_unit_staff@tamu.edu') do |major_unit_staff|
    major_unit_staff.first_name = 'Demo Major',
                                  major_unit_staff.last_name = 'Staff',
                                  major_unit_staff.provider = 'preloaded_google',
                                  major_unit_staff.unit = major,
                                  major_unit_staff.minor = nil,
                                  major_unit_staff.major = 'Demo Major',
                                  major_unit_staff.unit_name = 'Demo Major Staff',
                                  major_unit_staff.admin_flag = false
  end

  User.find_or_create_by(email: 'dummy_cmdt_staff@tamu.edu') do |cmdt_staff|
    cmdt_staff.first_name = 'Demo CMDT',
                            cmdt_staff.last_name = 'Staff',
                            cmdt_staff.provider = 'preloaded_google',
                            cmdt_staff.unit = cmdt,
                            cmdt_staff.minor = nil,
                            cmdt_staff.major = nil,
                            cmdt_staff.unit_name = 'Demo CMDT Staff',
                            cmdt_staff.admin_flag = false
  end

  @user = User.find_or_create_by(email:) do |user|
    user.first_name = first_name
    user.last_name = last_name
    user.uid = '123456789'
    user.provider = 'google_oauth2'
    user.unit = outfit
    user.admin_flag = false
  end
end

Given('I have logged in through the website home page') do
  visit home_path
  click_button 'Login with Google'
end

Given('I am a logged-in user with name {string}') do |name|
  step "I am a user with name \"#{name}\""
  step 'I have logged in through the website home page'
end
