module MonitoringHelper

  def time_resolution_options
    [
        ["30 sec", "30"],
        ["1 min", "60"],
        ["5 min", "300"],
        ["30 min", "1800"],
        ["1 h", "3600"]
    ].reverse
  end

  def hour_options
    hours = []

    0.upto(24) do |hour|
      hours << [ "#{hour}:00", "#{hour}:00:00"]
    end

    hours
  end

end
