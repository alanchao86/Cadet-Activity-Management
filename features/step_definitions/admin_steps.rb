
Given('I am an logged-in admin user with name {string}') do |name|

  name_parts = name.split
  first_name = name_parts.first
  last_name = name_parts[1..].join(' ') # Joins the rest of the parts as the last name.
  email = "#{first_name.downcase}#{last_name.downcase}@tamu.edu"

  cmdt = Unit.find_or_create_by(name: 'CMDT staff', cat: 'cmdt')
  major = Unit.create(name: 'Demo Major', cat: 'major', email: 'dummy_major_unit@tamu.edu', parent: cmdt)
  minor = Unit.create(name: 'Demo Minor', cat: 'minor', email: 'dummy_minor_unit@tamu.edu', parent: major)
  outfit = Unit.create(name: 'Demo Outfit', cat: 'outfit', email: 'dummy_outfit_unit@tamu.edu', parent: minor)

  user = User.find_or_create_by(email:) do |user|
    user.first_name = first_name
    user.last_name = last_name
    user.uid = '123456789'
    user.provider = 'google_oauth2'
    user.unit = outfit
    user.admin_flag = true
  end

  user2 = User.find_or_create_by(email: 'bobsmith@tamu.edu') do |user|
    user.first_name = 'Bob'
    user.last_name = 'Smith'
    user.provider = 'preloaded_google'
    user.unit = outfit
    user.admin_flag = false
  end

  step 'I have logged in through the website home page'
end

Then("I should see {string} on the nav bar") do |text|
  expect(page).to have_text(text)
end

Then("I should be on the Admin page") do
  expect(current_path).to eq(admin_index_path)
end

Given("I am on the new user data page") do
  visit new_admin_path
end

When("I fill out all forms") do
  fill_in "First Name", with: "Alice"
  fill_in "Last Name", with: "Smith"
  fill_in "Email", with: "alicesmith@tamu.edu"
  select "Demo Outfit", from: "Outfit"
end

When("I click the {string} button") do |button_text|
  click_button button_text
end

And("I should be redirected to the Admin Page") do
  expect(current_path).to eq(admin_index_path)
end

# Import File
Given("I am on the admin page") do
  visit admin_index_path
end

And("I click the Browse button and choose a CSV file") do
  attach_file('file', Rails.root.join('spec/fixtures/files/demoCorpsRoster.csv'))
end

# Impersonate
And('I click the "impersonate" button for the user {string}') do |user_name|
  email = "bobsmith@tamu.edu"

  within("tbody") do
    user_row = find('tr', text: email)
    within(user_row) do
      click_button "Impersonate"
    end
  end
end

# Delete
Given("I am on the user detail page") do
  # User.all.each { |user| puts user.email }
  user = User.find_by(email: "bobsmith@tamu.edu")
  visit admin_path(user)
end

When("I click the delete button") do
  click_button "Delete"
end

Then("I should see {string}") do |message|
  expect(page).to have_content(message)
end
