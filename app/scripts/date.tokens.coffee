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

class InToken extends StaticToken
  constructor: -> super "in"

class AToken extends StaticToken
  constructor: -> super "a"

class WeekendToken extends AbstractToken
  constructor: -> super /// (week-end|weekend)s? ///

class PMAMToken extends AbstractToken
  constructor: -> super /// pm|am|hr?s? ///
  value: -> @match[0]

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

class TonightToken extends StaticToken
  constructor: -> super "tonight"

class NightToken extends StaticToken
  constructor: -> super "night"

class MorningToken extends StaticToken
  constructor: -> super "morning"

class AfternoonToken extends StaticToken
  constructor: -> super "afternoon"

class EveningToken extends StaticToken
  constructor: -> super "evening"

class DinnerToken extends StaticToken
  constructor: -> super "dinner"

class BreakfastToken extends StaticToken
  constructor: -> super "breakfast"

class BrunchToken extends StaticToken
  constructor: -> super "brunch"

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

class DayNumberToken extends AbstractToken
  constructor: -> super /// ([0-9]{1,2})(th|nd|rd|st) ///
  value: -> parseInt @match[1]

class Number2Token extends AbstractToken
  constructor: -> super /// [0-9]{1,2} ///
  value: -> parseInt @match[0]

class Number2PToken extends AbstractToken
  constructor: -> super /// ([0-9]{1,2})(pm?|am?|hr?s?) ///
  value: -> parseInt @match[1]
  pmam: -> @match[2]

class TimeToken extends AbstractToken
  constructor: -> super /// ([0-9]{1,2}):([0-9]{2}) ///
  hours: -> parseInt @match[1]
  minutes: -> parseInt @match[2]

class TimePToken extends AbstractToken
  constructor: -> super /// ([0-9]{1,2}):([0-9]{2})(pm?|am?|hr?s?) ///
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

###################################
# All the tokens used for parsing #
###################################

Tokens = [
  DayNameToken, # "monday"
  MonthNameToken, # "january"
  AtToken, # "at"
  MonthToken, # "month"
  WeekToken, # "week"
  YearToken, # "year"
  NoonToken, # "noon"
  MidnightToken, # "midnight"
  LunchToken, # "lunch"
  TodayToken, # "today"
  TomorrowToken, # "tomorrow"
  YesterdayToken, # "yesterday"
  NextLastToken, # "next|last"
  DayNumberToken, # "28th"
  Number2Token, # "28"
  Number2PToken, # "28PM"
  TimeToken, # "7:30"
  TimePToken, # "7:30PM"
  Number4Token, # "2012"
  DateYYToken, # "8/25/12"
  DateYYYYToken, # "8/25/2012"
  PMAMToken, # "pm|am"
  InToken, # "in"
  AToken, # "a"
  WeekendToken, # "weekend"
  MorningToken, # "morning"
  AfternoonToken, # "afternoon"
  EveningToken, # "evening"
  DinnerToken, # "dinner"
  BreakfastToken, # "breakfast"
  BrunchToken, # "brunch"
  TonightToken, # "tonight"
  NightToken, # "night"
]
