class ScalingRule < ActiveRecord::Base

  def as_string
    string_form = "if #{self.metric_name.split(".").last} on #{self.metric_name.split(".").first}" +
    " is #{self.condition} #{self.threshold}"

    if self.measurement_type == "time_window"
      string_form += " in last #{self.time_window_length} #{time_window_length_unit}"
    end

    string_form += " than '#{self.action}'"

    string_form
  end

  def time_window_length_in_secs
    if time_window_length_unit == "s"
      time_window_length
    elsif time_window_length_unit == "m"
      time_window_length*60
    elsif time_window_length_unit == "h"
      time_window_length*3600
    end
  end

end
