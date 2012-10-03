# Date.coffee
# (c) BeSport 2012, François-Xavier Thomas

########################
# Grammar base classes #
########################

class Rule
  constructor: (@classes) ->
    @length = @classes.length
    @info = {}

  match: (tokens) ->
    matches = (tokens[k] for cls,k in @classes when tokens[k] instanceof cls)
    matched = (matches.length == @classes.length)
    if matched
      @info = @value matches
    return matched

  value: (tokens) -> {}

class SingleTokenRule extends Rule
  constructor: (cls) ->
    super [cls]

class NextLastRule extends Rule
  constructor: (cls, @property) -> super [NextLastToken, cls]
  value: (tokens) ->
    r = {}
    r[@property] = tokens[0].value()
    return r

#################
# Grammar rules #
#################
#
class WeekdayMonthDayOrdYearRule extends Rule
  constructor: -> super [DayNameToken, MonthNameToken, DayNumberToken, Number4Token]
  value: (tokens) -> { month: tokens[1].id(), day: tokens[2].value(), year: tokens[3].value() }

class MonthDayOrdYearRule extends Rule
  constructor: -> super [MonthNameToken, DayNumberToken, Number4Token]
  value: (tokens) -> { month: tokens[0].id(), day: tokens[1].value(), year: tokens[2].value() }

class WeekdayMonthDayOrdRule extends Rule
  constructor: -> super [DayNameToken, MonthNameToken, DayNumberToken]
  value: (tokens) -> { month: tokens[1].id(), day: tokens[2].value() }

class MonthDayOrdRule extends Rule
  constructor: -> super [MonthNameToken, DayNumberToken]
  value: (tokens) -> { month: tokens[0].id(), day: tokens[1].value() }

class WeekdayMonthDayYearRule extends Rule
  constructor: -> super [DayNameToken, MonthNameToken, Number2Token, Number4Token]
  value: (tokens) -> { month: tokens[1].id(), day: tokens[2].value(), year: tokens[3].value() }

class MonthDayYearRule extends Rule
  constructor: -> super [MonthNameToken, Number2Token, Number4Token]
  value: (tokens) -> { month: tokens[0].id(), day: tokens[1].value(), year: tokens[2].value() }

class WeekdayMonthDayRule extends Rule
  constructor: -> super [DayNameToken, MonthNameToken, Number2Token]
  value: (tokens) -> { month: tokens[1].id(), day: tokens[2].value() }

class MonthDayRule extends Rule
  constructor: -> super [MonthNameToken, Number2Token]
  value: (tokens) -> { month: tokens[0].id(), day: tokens[1].value() }

class DateYYTokenRule extends SingleTokenRule
  constructor: -> super DateYYToken
  value: (tokens) -> { year: tokens[0].year(), day: tokens[0].day(), month: tokens[0].month() }

class DateYYYYTokenRule extends SingleTokenRule
  constructor: -> super DateYYYYToken
  value: (tokens) -> { year: tokens[0].year(), day: tokens[0].day(), month: tokens[0].month() }

class DayTokenRule extends SingleTokenRule
  constructor: -> super DayNameToken
  value: (tokens) -> { next_week_day: tokens[0].id() }

class MonthTokenRule extends SingleTokenRule
  constructor: -> super MonthNameToken
  value: (tokens) -> { month: tokens[0].id() }

class TomorrowRule extends SingleTokenRule
  constructor: -> super TomorrowToken
  value: (tokens) -> { day_add: +1 }

class YesterdayRule extends SingleTokenRule
  constructor: -> super YesterdayToken
  value: (tokens) -> { day_add: -1 }

class TodayRule extends SingleTokenRule
  constructor: -> super TodayToken
  value: (tokens) -> { day_add: 0 }

class NoonRule extends SingleTokenRule
  constructor: -> super NoonToken
  value: (tokens) -> { hours: 12, minutes: 0, seconds: 0 }

class LunchRule extends SingleTokenRule
  constructor: -> super LunchToken
  value: (tokens) -> { hours: 12, minutes: 0, seconds: 0 }

class MidnightRule extends SingleTokenRule
  constructor: -> super MidnightToken
  value: (tokens) -> { hours: 0, minutes: 0, seconds: 0 }

class NextLastWeekRule extends NextLastRule
  constructor: -> super WeekToken,"week_add"

class NextLastMonthRule extends NextLastRule
  constructor: -> super MonthToken,"month_add"

class NextLastYearRule extends NextLastRule
  constructor: -> super YearToken,"year_add"

class NextLastDayRule extends Rule
  constructor: -> super [NextLastToken, DayNameToken]
  value: (tokens) ->
    r = {}
    v = tokens[0].value()
    r[if v < 0 then "last_week_day" else "next_week_day"] = tokens[1].id()
    return r

class NumberAtRule extends Rule
  constructor: -> super [AtToken, Number2Token]
  value: (tokens) -> { hours: tokens[1].value(), minutes: 0, seconds: 0 }

class NumberPRule extends SingleTokenRule
  constructor: -> super Number2PToken
  value: (tokens) -> { hours: tokens[0].value(), minutes: 0, seconds: 0, pmam: tokens[0].pmam() }

class TimeRule extends SingleTokenRule
  constructor: -> super TimeToken
  value: (tokens) -> { hours: tokens[0].hours(), minutes: tokens[0].minutes(), seconds: 0 }

class TimeSpacePRule extends Rule
  constructor: -> super [TimeToken, PMAMToken]
  value: (tokens) -> { hours: tokens[0].hours(), minutes: tokens[0].minutes(), seconds: 0, pmam: tokens[1].value() }

class NumberTimeSpacePRule extends Rule
  constructor: -> super [Number2Token, PMAMToken]
  value: (tokens) -> { hours: tokens[0].value(), minutes: 0, seconds: 0, pmam: tokens[1].value() }

class AtNumberTimeSpacePRule extends Rule
  constructor: -> super [AtToken, Number2Token, PMAMToken]
  value: (tokens) -> { hours: tokens[1].value(), minutes: 0, seconds: 0, pmam: tokens[2].value() }

class TimePRule extends SingleTokenRule
  constructor: -> super TimePToken
  value: (tokens) ->
    { hours: tokens[0].hours(), minutes: tokens[0].minutes(), seconds: 0, pmam: tokens[0].pmam() }

##################################
# All the rules used for parsing #
##################################

Rules = [
  # Basic rules
  DayTokenRule, # "monday"
  MonthTokenRule, # "january"
  TomorrowRule, # "tomorrow"
  YesterdayRule, # "yesterday"
  TodayRule, # "today"

  # Next/Last
  NextLastMonthRule, # "next month"
  NextLastYearRule, # "next year"
  NextLastDayRule, # "next monday"
  NextLastWeekRule, # "next week"

  # Times #
  NumberAtRule, # "at 7"
  NumberPRule, # "7pm"
  TimeRule, # "7:30"
  TimePRule, # "7:30PM"
  TimeSpacePRule, # "7:28 PM"
  NumberTimeSpacePRule, # "7 PM"
  AtNumberTimeSpacePRule, # "at 7 PM"

  # Special times #
  LunchRule, # "lunch"
  NoonRule, # "noon"
  MidnightRule, # "midnight"

  # Slash dates
  DateYYTokenRule, # "mm/dd/yy"
  DateYYYYTokenRule, # "mm/dd/yyyy"

  # Dates with numbers
  MonthDayYearRule, # "january, 28, 2012"
  WeekdayMonthDayYearRule, # "monday, january 28 2012"
  MonthDayRule, # "january 28"
  WeekdayMonthDayRule, # "monday, january 28"

  # Dates with ordinals
  MonthDayOrdYearRule, # "january, 28th 2012"
  WeekdayMonthDayOrdYearRule, # "monday, january 28th 2012"
  MonthDayOrdRule, # "january 28th"
  WeekdayMonthDayOrdRule # "monday, january 28th"
]
