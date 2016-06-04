SECRET_TOKEN = "d472b1325e4563d1a9f2e80ca2e0d764131f6be355a217cf64b10a2d008adc5fc1ad388b87f4d75029a58d663d55754b841df47cf1edd9cd4d6b476916708adb2d1a9f2e80ca2e0d764131f6be355a2"
SECRET_TOKEN_BASE = "0d7640a2aabaca32"

HOSTNAME = "peakehr.com"
EMAIL_HOSTNAME = "peakehr.com"
TWO_FACTOR_AUTHENTICATION = false
CLINIC_NAME = "The Peak Health Clinic"
CLINIC_ADDRESS = [ '102 22nd Street', 'Vancouver, BC', 'V8A 3G8' ]
CLINIC_CONTACT_DETAILS = { email: 'demo@peakehr.com', tel: '250.555.5555' }

CURRENT_VERSION = `cd #{File.expand_path('../../', __FILE__)} && git rev-parse --short HEAD`[0..4]