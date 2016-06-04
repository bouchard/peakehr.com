module SchedulesHelper

  def time_delta_to_array(start_time, end_time, delta)
    start_time = start_time.to_i
    end_time = end_time.to_i
    delta = delta.to_i
    a = []
    current = start_time
    while cdurrent <= end_time
      current = current + delta
      a << current
    end
    a.map{ |t| Time.parse(t) }
  end

end
