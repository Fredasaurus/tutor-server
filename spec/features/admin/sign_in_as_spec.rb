require 'rails_helper'

RSpec.feature 'Administrator' do
  scenario 'signs in as another user' do
    user = FactoryGirl.create(:user_profile, username: 'a_user')

    admin = FactoryGirl.create(:user_profile, :administrator)
    # FIXME login without using the accounts dev tool
    routes = OpenStax::Accounts::Engine.routes.url_helpers
    page.driver.post(routes.become_dev_account_path(admin.account.openstax_uid))

    visit admin_root_path
    click_link 'Users'
    fill_in 'search_term', with: 'a_user'
    click_button 'Search'
    click_link 'Sign in as', match: :first

    expect(current_path).to eq(dashboard_path)
    # a_user is not an admin so should not be able to see the admin console
    expect { visit admin_root_path }.to raise_error(SecurityTransgression)
    visit copyright_path
    expect(page).to have_content('signed in as a_user')
  end
end
