# frozen_string_literal: true

# Date helpers for date math
class DateService
  # how many weeks have days that count as part of this month?
  # i.e. Jan 2021:
  #  M   T   W   R   F   S   S
  #                  1   2   3
  #  4   5   6   7   8   9  10
  # 11 .......................
  # 18 .......................
  # 25  26  27  28  29  30  31
  #
  # there are 5 weeks with days in Jan 2021
  #
  # we do this so we can calculate *APPROXIMATELY* how many
  # attendances kids are allowed per month, because their
  # approval letter will say "4 part days per week", etc.
  # this is a business logic TODO for us once we start to get
  # a better idea of how this works in practice
  def self.weeks_in_month(date)
    (date.to_date.all_month.count / 7.0).ceil
  end

  def self.remaining_days_in_month_including_today(date, day_of_week)
    num_remaining_this_month = (date.to_date..date.to_date.at_end_of_month).count { |day| day_of_week == day.wday }
    num_remaining_this_month.positive? ? num_remaining_this_month : 0
  end
end
