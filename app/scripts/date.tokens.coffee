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
