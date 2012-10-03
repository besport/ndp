# Date.coffee
# (c) BeSport 2012, François-Xavier Thomas

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
  word_list = (a for a in str.split /\s*,\s*|\s*;\s*|\s*\.\s+|\s+/ when a.length > 0)

  # Tokenize input
  tokens = (to_token(a) for a in word_list)
  tokens = (a for a in tokens when a isnt null)

  # Apply rules
  rules = []
  while tokens.length
    p = pick tokens
    rules.push p if p isnt null

  # Copy input date (or create it if null)
  date = if date then new Date date else new Date

  # Apply modifiers
  apply r.info,date for r in rules

  # Return null if nothing can be parsed
  return date
