# Date.coffee
# (c) BeSport 2012, François-Xavier Thomas

# These don't actually do anything, but have to be concatenated to the main
# file. It's easier to split the code that way.

#include ./date.tokens.coffee
#include ./date.rules.coffee

##################
# Useful methods #
##################

pick = (token_list) ->
  max_rule = null
  for R in Rules
    r = new R
    if (r.match token_list) and (max_rule is null or r.length > max_rule.length)
      max_rule = r

  l = if max_rule isnt null then max_rule.length else 1
  token_list.splice(0,1) while (l -= 1) + 1
    
  return max_rule

apply = (info, date=new Date) ->
  # Apply static time information
  if "hours" of info
    date.setHours info.hours + (if "pmam" of info and info.pmam == "p" then 12 else 0)

  # Set minutes
  if "minutes" of info
    date.setMinutes info.minutes

  # Set seconds
  if "seconds" of info
    date.setSeconds info.seconds

  if "month" of info
    date.setMonth info.month

  if "year" of info
    date.setYear info.year

  if "day" of info
    date.setDate info.day

  # Set next week day
  if "next_week_day" of info
    current_day = date.getDay()
    day = info.next_week_day
    date.setTime (date.getTime() + (day-current_day)*Date.Util.Interval.Day + if day <= current_day then 7*Date.Util.Interval.Day else 0)

  # Set last week day
  if "last_week_day" of info
    current_day = date.getDay()
    day = info.last_week_day
    date.setTime (date.getTime() + (day-current_day)*Date.Util.Interval.Day - if day >= current_day then 7*Date.Util.Interval.Day else 0)

  # Apply time shift, if any
  if "time_add" of info
    date.setTime (date.getTime() + info.time_add)

  # Apply second shift, if any
  if "seconds_add" of info
    date.setTime (date.getTime() + info.seconds_add*Date.Util.Interval.Second)

  # Apply minute shift, if any
  if "minutes_add" of info
    date.setTime (date.getTime() + info.minutes_add*Date.Util.Interval.Minute)

  # Apply hour shift, if any
  if "hours_add" of info
    date.setTime (date.getTime() + info.hours_add*Date.Util.Interval.Hour)

  # Apply day shift, if any
  if "day_add" of info
    date.setTime (date.getTime() + info.day_add*Date.Util.Interval.Day)
    
  # Apply week shift, if any
  if "week_add" of info
    date.setTime (date.getTime() + info.week_add*Date.Util.Interval.Week)

  # Apply month shift, if any
  if "month_add" of info
    date.setMonth (date.getMonth() + info.month_add)

  # Apply year shift, if any
  if "year_add" of info
    date.setYear (date.getFullYear() + info.year_add)

  return date

#######################
# Main parsing method #
#######################

Date.parse = (str, date) ->
  # Transform str to lowercase
  str = str.toLowerCase()

  # Transform input into a list of words
  word_list = (a for a in str.split /\s*[,;!?]\s*|\s*\.\s+|\s+/ when a.length > 0)

  # Tokenize input
  tokens = (to_token(a) for a in word_list)
  tokens = (a for a in tokens when a isnt null)

  # Apply rules
  rules = []
  while tokens.length
    p = pick tokens
    rules.push p if p isnt null

  # Return null if nothing found
  return null if rules.length == 0

  # Copy input date (or create it if null)
  date = if date then new Date date else new Date

  # Apply modifiers
  apply r.info,date for r in rules

  # Return null if nothing can be parsed
  return date

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

class TimePRule extends SingleTokenRule
  constructor: -> super TimePToken
  value: (tokens) ->
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
  MidnightRule,
  DateYYTokenRule,
  DateYYYYTokenRule,
  MonthDayYearRule,
  WeekdayMonthDayYearRule,
  MonthDayRule,
  WeekdayMonthDayRule
]

# Date.coffee
# (c) BeSport 2012, François-Xavier Thomas

##################################
# Some useful global definitions #
##################################

Date.Util = {
  Interval: {
    Second: 1000,
    Minute: 60*1000,
    Hour: 60*60*1000,
    Day: 24*60*60*1000,
    Week: 7*24*60*60*1000
  },
  Day: {
    Full:   ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"],
    Abbrev: ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
  },
  Month: {
    Full:   ["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"],
    Abbrev: ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
  }
}

######################
# Base token classes #
######################

class AbstractToken
  constructor: (@regexp) ->

  use: (str) ->
    @match = str.match @regexp
    return @match isnt null and @match[0].length == str.length

  value: -> @match[0]

class StaticToken extends AbstractToken
  constructor: (str) -> super /// #{str} ///

class ListToken extends StaticToken
  constructor: (@list) -> super @list.join "|"
  id: ->
    @list.indexOf @match[0][0..2]

class AbbrevListToken extends ListToken
  constructor: (list) ->
    l = []
    l.push d for d in list.Full
    l.push d for d in list.Abbrev
    super l
    @list = list.Abbrev

###################
# Day/Month names #
###################

class DayNameToken extends AbbrevListToken
  constructor: -> super Date.Util.Day

class MonthNameToken extends AbbrevListToken
  constructor: -> super Date.Util.Month

#################
# Static tokens #
#################

class AtToken extends StaticToken
  constructor: -> super "at"

class MonthToken extends StaticToken
  constructor: -> super "month"

class WeekToken extends StaticToken
  constructor: -> super "week"

class YearToken extends StaticToken
  constructor: -> super "year"

class NoonToken extends StaticToken
  constructor: -> super "noon"

class MidnightToken extends StaticToken
  constructor: -> super "midnight"

class LunchToken extends StaticToken
  constructor: -> super "lunch"

class TodayToken extends StaticToken
  constructor: -> super "today"

class TomorrowToken extends StaticToken
  constructor: -> super "tomorrow"

class YesterdayToken extends StaticToken
  constructor: -> super "yesterday"

class NextToken extends StaticToken
  constructor: -> super "next"

class LastToken extends StaticToken
  constructor: -> super "last"

class NextLastToken extends AbstractToken
  constructor: -> super /// next|last ///
  value: -> if @match[0] == "next" then 1 else if @match[0] == "last" then  -1 else 0

###########
# Numbers #
###########

class DateYYToken extends AbstractToken
  constructor: -> super /// ([0-9]{1,2})[./]([0-9]{1,2})[./]([0-9]{2}) ///
  use: (str) -> (super str) and @day() <= 31 and @day() > 0 and @month() <= 11 and @month() >= 0
  month: -> (parseInt @match[1])-1
  day: -> parseInt @match[2]
  year: -> 2000 + parseInt @match[3]

class DateYYYYToken extends AbstractToken
  constructor: -> super /// ([0-9]{1,2})[./]([0-9]{1,2})[./]([0-9]{4}) ///
  use: (str) -> (super str) and @day() <= 31 and @day() > 0 and @month() <= 11 and @month() >= 0
  month: -> (parseInt @match[1])-1
  day: -> parseInt @match[2]
  year: -> parseInt @match[3]

class Number2Token extends AbstractToken
  constructor: -> super /// [0-9]{1,2} ///
  value: -> parseInt @match[0]

class Number2PToken extends AbstractToken
  constructor: -> super /// ([0-9]{1,2})(p|a)m? ///
  value: -> parseInt @match[1]
  pmam: -> @match[2]

class TimeToken extends AbstractToken
  constructor: -> super /// ([0-9]{1,2}):([0-9]{2}) ///
  hours: -> parseInt @match[1]
  minutes: -> parseInt @match[2]

class TimePToken extends AbstractToken
  constructor: -> super /// ([0-9]{1,2}):([0-9]{2})(p|a)m? ///
  hours: -> parseInt @match[1]
  minutes: -> parseInt @match[2]
  pmam: -> @match[3]

class Number4Token extends AbstractToken
  constructor: -> super /// [0-9]{4} ///
  value: -> parseInt @match[0]

to_token = (word) ->
  for Token in Tokens
    t = new Token
    if t.use word
      return t

  return null

Tokens = [
  DayNameToken,
  MonthNameToken,
  AtToken,
  MonthToken,
  WeekToken,
  YearToken,
  NoonToken,
  MidnightToken,
  LunchToken,
  TodayToken,
  TomorrowToken,
  YesterdayToken,
  NextLastToken,
  Number2Token,
  Number2PToken,
  TimeToken,
  TimePToken,
  Number4Token,
  DateYYToken,
  DateYYYYToken
]
