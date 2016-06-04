require 'spec_helper'

describe 'the sign in process' do
  before :each do
    Staff.all.map(&:destroy)
    @user = create(:user)
  end

  it 'signs me in' do
    visit '/session/new'
    within('.sign-in') do
      fill_in 'user_username', with: @user.username
      fill_in 'user_password', with: @user.password
    end
    click_button 'Sign in'
    page.should have_content 'sign out'
  end
end