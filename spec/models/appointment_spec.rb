require 'spec_helper'

describe Appointment do
  before :all do
    Appointment.all.map(&:destroy)
    @patient ||= create(:patient)
    @user ||= create(:user)
    @appointment = create(:appointment, patient: @patient, user: @user)
  end

  it 'should have a valid factory' do
    @appointment.should be_valid
  end

  it 'rejects a booking date in the past' do
    @appointment.booked_at = 10.minutes.ago
    @appointment.should_not be_valid
  end
end
