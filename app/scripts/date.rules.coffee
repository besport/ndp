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

class TimePRule extends SingleTokenRule
  constructor: -> super TimePToken
  value: (tokens) ->
    console.log tokens
    { hours: tokens[0].hours(), minutes: tokens[0].minutes(), seconds: 0, pmam: tokens[0].pmam() }

##################################
# All the rules used for parsing #
##################################

Rules = [
  DayTokenRule,
  MonthTokenRule,
  TomorrowRule,
  YesterdayRule,
  TodayRule,
  NextLastMonthRule,
  NextLastYearRule,
  NextLastDayRule,
  NextLastWeekRule,
  NumberAtRule,
  NumberPRule,
  NumberPRule,
  TimeRule,
  TimePRule,
  LunchRule,
  NoonRule,
  MidnightRule
]
