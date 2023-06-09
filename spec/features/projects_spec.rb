=begin

- Capybara is used to simulate browser interactions
  - visit, click_link, fill_in + with, click_button, check, uncheck, select, attach_file
  - By default, it runs tests using a headless browser, but inserting "save_and_open_page" allows]
    the HTML delivered from the Rails application

- In case of scenario "user creates a new project", spec uses the same web form our application's users would use.

- Within feature specs, you can have multiple expectations in a given example or scenario.

- "sign_in" method from Devise helper

- "feature" & "scenario" are part of Capybara
  - "feature" is equivalent to "describe" / "context" in RSpec
  - "scenario" is equivalent to "it" / "example" in RSpec

=end

require 'rails_helper'

RSpec.feature "Projects", type: :feature do
  scenario "user creates a new project" do
    user = FactoryBot.create(:user)
    # using our customer login helper:
    # sign_in_as user
    # or the one provided by Devise:
    sign_in user

    visit root_path

    expect {
      click_link "New Project"
      fill_in "Name", with: "Test Project"
      fill_in "Description", with: "Trying out Capybara"
      click_button "Create Project"
      #save_and_open_page

      aggregate_failures do
        expect(page).to have_content "Project was successfully created"
        expect(page).to have_content "Test Project"
        expect(page).to have_content "Owner: #{user.name}"
      end
    }.to change(user.projects, :count).by(1)
  end

  scenario "user completes a project", focus: true do
    # given a user with a project
    # and that the user is logged in
    # when the user visits the project page
    # and the user clicks the "complete" button
    # then the project is marked as complete
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project, owner: user)
    login_as user, scope: :user

    visit project_path(project)

    expect(page).to_not have_content "Completed"

    click_button "Complete"

    expect(project.reload.completed?).to be true
    expect(page).to \
      have_content "Congratulations, this project is complete!"
    expect(page).to have_content "Completed"
    expect(page).to_not have_button "Complete"
  end
end