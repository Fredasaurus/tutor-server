require 'rails_helper'

RSpec.feature 'Administration' do
  scenario 'create a blank course' do
    admin = FactoryGirl.create(:user_profile, :administrator)
    stub_current_user(admin)

    visit admin_courses_path
    click_link 'Add Course'

    fill_in 'Name', with: 'Hello World'
    click_button 'Save'

    expect(current_path).to eq(admin_courses_path)
    expect(page).to have_css('.flash_notice', text: 'The course has been created.')
    expect(page).to have_css("tr td", text: 'Hello World')
  end
end
