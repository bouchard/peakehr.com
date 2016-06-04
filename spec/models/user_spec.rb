require 'spec_helper'

describe Staff do
  before :all do
    Staff.all.map(&:destroy)
    @user ||= create(:user)
  end

  it 'should have a valid factory' do
    @user.should be_valid
  end
end
