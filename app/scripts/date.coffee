# Date.coffee
# (c) BeSport 2012, François-Xavier Thomas

Date.Util = {
  Day: {
    Full:   ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"],
    Abbrev: ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
  },

  Interval: {
    Second: 1000,
    Minute: 60*1000,
    Hour: 60*60*1000,
    Day: 24*60*60*1000,
    Week: 7*24*60*60*1000
  }
}

Date.Parser = {
  Expressions: {
    "today": {},
    "tomorrow": {day_add: 1},
    "yesterday": {day_add: -1},
    "next week": {week_add: 1},
    "last week": {week_add: -1},
    "next month": {month_add: 1},
    "last month": {month_add: -1},
    "next year": {year_add: 1},
    "last year": {year_add: -1},
    "noon": {hour: 12, minutes: 0}
    "midnight": {hour: 0, minutes: 0}
  },

  RegularExpressions: [
    {
      expression: /// ([0-9]?[0-9]):([0-9]{2}) ///,
      attributes: { hours: 1, minutes: 2 }
    },
    {
      expression: /// ([0-9]?[0-9]):([0-9]{2})(p|a)m? ///,
      attributes: { hours: 1, minutes: 2, pmam: 3}
    }
  ]
}

infoFromString = (str, expr) ->
  attr = expr.attributes
  expr = str.match expr.expression
  if expr
    retn = {}
    retn[key] = expr[val] for key,val of attr
    return retn
  else
    return null

apply = (info, date=new Date()) ->
  # Apply static time information
  if "hours" of info
    date.setHours parseInt(info.hours) + (if "pmam" of info and info.pmam == "p" then 12 else 0)
    console.log (info)

  if "minutes" of info
    date.setMinutes parseInt(info.minutes)

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
    date.setYear (date.getYear() + info.year_add)

  return date

Date.parse = (str, date) ->
  # Transform str to lowercase
  str = str.toLowerCase()

  # Copy input date (or create it if null)
  date = if date then new Date(date) else new Date()

  # Parse simple expressions
  date = apply info,date for expr,info of Date.Parser.Expressions when (str.indexOf expr) >= 0
  date = apply info,date for info in (infoFromString str,expr for expr in Date.Parser.RegularExpressions) when info

  # Return null if nothing can be parsed
  return date
