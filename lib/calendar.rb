class Calendar
  def initialize(*args)
    args = args.first if args.is_a?(Array)
    @clinician_id = args[:clinician_id]
    @date = args[:date]
  end

  def clinician
    @_clinician ||= Staff.where(id: @clinician_id).first
  end

  def workday
    @_workday ||= self.clinician.workdays.where(date: @date).first_or_initialize
  end

  def appointments
    @_appts ||= self.clinician.appointments.by_date(@date)
  end

  # For Rails cache calculation purposes.
  def updated_at
    self.workday.updated_at
  end

  def as_json(*args)
    Rails.cache.fetch([ 'calendar', (self.workday.id || Time.now) ]) do
      {
        clinician: self.clinician.as_json(only: [ :id, :username ], methods: [ :full_name_with_title ]),
        workday: self.workday.as_json(only: [ :id, :staff_id ], methods: [ :office_hours ]),
        appointments: self.appointments.includes(:patient).as_json(
          only: [ :id, :patient_id, :workday_id, :booked_at, :length_in_seconds, :one_liner ],
          include: {
            patient: {
              only: [ :id ], methods: [ :full_name, :date_of_birth, :sex ]
            }
          }
        )
      }
    end
  end

end