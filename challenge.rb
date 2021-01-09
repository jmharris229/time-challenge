#  NOTES
#  Two arguments: a time, and a integer of minutes. for example, ("9:15 AM", 200)
#  The problem does not state that it needs to subtract time, BUT assume it should be able to
#  Problem: take first argument and add the minutes to the first argument, return the new time as a string
#  example response: addTime("9:15 AM", 30) returns "9:45 AM"
#  Write tests for validity and edge cases
#  CANNOT USE date functions
#  Need to keep track of AM and PM. If a time passes 12, it needs to flip to the opposite.
#  If the time passes 12:59, it needs to reset back to 1, not 13.

def day_in_seconds
  1000 * 60 * 60 * 24
end

def hour_in_seconds
  1000 * 60 * 60
end

def handle_crossing_day(total_seconds, new_total_seconds, minutes_to_change_by_in_seconds)
  if new_total_seconds >= day_in_seconds
    # scenario for multi day minute add
    # meaning the minutes you are adding is greater than the amount in a day
    if minutes_to_change_by_in_seconds >= day_in_seconds
      # days are irrelevant when dealing with just time, as its circular.
      # so we want the remainder of the minute change / day in seconds.
      single_day_change = minutes_to_change_by_in_seconds % day_in_seconds
      # we can then add this to our total seconds and if we still crossed a new day, subtract
      pre_nts = total_seconds + single_day_change
      new_total_seconds = pre_nts - (pre_nts >= day_in_seconds ? day_in_seconds : 0)
    else
      new_total_seconds = new_total_seconds - day_in_seconds
    end
  elsif new_total_seconds <= 0
    if (minutes_to_change_by_in_seconds / day_in_seconds) < -1
      single_day_change = minutes_to_change_by_in_seconds % day_in_seconds
      new_total_seconds = (total_seconds - (single_day_change).abs).abs
    else
      # going back in time from 12:05 to 11:55 the previous day
      new_total_seconds = day_in_seconds - (new_total_seconds).abs
    end
  end
end

def update_time(time, minutes_to_change_by)
  begin
    # get each individual time component
    # this will make it easier to do calculations on our time
    time_components = time.gsub(":", " ").split
    hour = time_components[0].to_i
    minute = time_components[1].to_i
    day_half = time_components[2]

    # we need a base time unit, convert everything to seconds
    current_hour_in_seconds = 1000 * 60 * 60 * ((day_half == "PM" && hour != 12) ? 12 + hour : hour); # if we are in the PM, we need to add 12, as 3PM is really the 15th hour on a 24 hour day
    current_minute_in_seconds = 1000 * 60 * minute;
    minutes_to_change_by_in_seconds = 1000 * 60 * minutes_to_change_by
    total_seconds = current_hour_in_seconds + current_minute_in_seconds;
    new_total_seconds = total_seconds + minutes_to_change_by_in_seconds

    # If the time crosses to the next day
    if new_total_seconds >= day_in_seconds || new_total_seconds <= 0
      new_total_seconds = handle_crossing_day(total_seconds, new_total_seconds, minutes_to_change_by_in_seconds)
    end

    # get new time components
    new_day_half = new_total_seconds < (day_in_seconds / 2) ? "AM" : "PM"
    floored_hour = (new_total_seconds / hour_in_seconds).floor
    floored_hour = (floored_hour == 0) ? 12 : floored_hour
    new_hour = floored_hour - ((new_day_half == "AM" || floored_hour == 12) ? 0 : 12)
    new_minute = ((new_total_seconds % hour_in_seconds) / 1000 / 60)

    # contruct the new time
    # rjust used to add zero padding, this is for on the hour times, e.g. 1:00
    new_hour.to_s + ":" + new_minute.to_s.rjust(2, '0') + " " + new_day_half
  rescue => e
    return e
  end
end

# --- TESTS ---

def test_runner(test_name, time_to_test, minute_change, expected_result)
  test_result = update_time(time_to_test, minute_change)
  if (test_result == expected_result)
    puts "#{test_name}: pass"
  else
    puts "#{test_name}: got #{test_result}, expected #{expected_result}"
  end
end


test_runner("coding assignment worksheet test", "9:13 AM", 200, "12:33 PM")

test_runner("simple add test", "3:27 PM", 3, "3:30 PM")
test_runner("medium add test", "3:30 AM", 46, "4:16 AM")
test_runner("big add test", "8:00 AM", 200, "11:20 AM")
test_runner("multi day add test", "12:00 PM", 5000, "11:20 PM")
test_runner("multi day add test 2", "12:00 PM", 5045, "12:05 AM")
test_runner("weird time add test", "8:59 AM", 185, "12:04 PM")
test_runner("weird time add test 2", "3:43 AM", 130, "5:53 AM")


test_runner("simple subtract test", "3:27 PM", -3, "3:24 PM")
test_runner("medium subtract test", "3:30 AM", -46, "2:44 AM")
test_runner("big subtract test", "9:00 AM", -200, "5:40 AM")
test_runner("multi day subtract test", "12:00 PM", -5000, "12:40 AM")
test_runner("multi day subtract test 2", "12:00 PM", -5045, "12:05 AM")
test_runner("weird time subtract test", "8:59 AM", -185, "5:54 AM")
test_runner("weird time subtract test 2", "3:43 AM", -130, "1:33 AM")


test_runner("crossing twelve PM add test", "9:00 AM", 200, "12:20 PM")
test_runner("crossing twelve PM subtract test", "1:00 PM", -120, "11:00 AM")

test_runner("crossing twelve AM add test", "11:00 PM", 120, "1:00 AM")
test_runner("crossing twelve AM subtract test", "1:00 AM", -120, "11:00 PM")

test_runner("error handling no initial time test", nil, -120, "11:00 PM")
test_runner("error handling no minute change test", "9:30 AM", nil, "11:00 PM")
# error handling
# expected to fail