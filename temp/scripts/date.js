(function() {
  var AbbrevListToken, AbstractToken, AtToken, DateYYToken, DateYYTokenRule, DateYYYYToken, DateYYYYTokenRule, DayNameToken, DayTokenRule, LastToken, ListToken, LunchRule, LunchToken, MidnightRule, MidnightToken, MonthDayRule, MonthDayYearRule, MonthNameToken, MonthToken, MonthTokenRule, NextLastDayRule, NextLastMonthRule, NextLastRule, NextLastToken, NextLastWeekRule, NextLastYearRule, NextToken, NoonRule, NoonToken, Number2PToken, Number2Token, Number4Token, NumberAtRule, NumberPRule, Rule, Rules, SingleTokenRule, StaticToken, TimePRule, TimePToken, TimeRule, TimeToken, TodayRule, TodayToken, Tokens, TomorrowRule, TomorrowToken, WeekToken, WeekdayMonthDayRule, WeekdayMonthDayYearRule, YearToken, YesterdayRule, YesterdayToken, apply, pick, to_token,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  pick = function(token_list) {
    var R, l, max_rule, r, _i, _len;
    max_rule = null;
    for (_i = 0, _len = Rules.length; _i < _len; _i++) {
      R = Rules[_i];
      r = new R;
      if ((r.match(token_list)) && (max_rule === null || r.length > max_rule.length)) {
        max_rule = r;
      }
    }
    l = max_rule !== null ? max_rule.length : 1;
    while ((l -= 1) + 1) {
      token_list.splice(0, 1);
    }
    return max_rule;
  };

  apply = function(info, date) {
    var current_day, day;
    if (date == null) {
      date = new Date;
    }
    if ("hours" in info) {
      date.setHours(info.hours + ("pmam" in info && info.pmam === "p" ? 12 : 0));
    }
    if ("minutes" in info) {
      date.setMinutes(info.minutes);
    }
    if ("seconds" in info) {
      date.setSeconds(info.seconds);
    }
    if ("month" in info) {
      date.setMonth(info.month);
    }
    if ("year" in info) {
      date.setYear(info.year);
    }
    if ("day" in info) {
      date.setDate(info.day);
    }
    if ("next_week_day" in info) {
      current_day = date.getDay();
      day = info.next_week_day;
      date.setTime(date.getTime() + (day - current_day) * Date.Util.Interval.Day + (day <= current_day ? 7 * Date.Util.Interval.Day : 0));
    }
    if ("last_week_day" in info) {
      current_day = date.getDay();
      day = info.last_week_day;
      date.setTime(date.getTime() + (day - current_day) * Date.Util.Interval.Day - (day >= current_day ? 7 * Date.Util.Interval.Day : 0));
    }
    if ("time_add" in info) {
      date.setTime(date.getTime() + info.time_add);
    }
    if ("seconds_add" in info) {
      date.setTime(date.getTime() + info.seconds_add * Date.Util.Interval.Second);
    }
    if ("minutes_add" in info) {
      date.setTime(date.getTime() + info.minutes_add * Date.Util.Interval.Minute);
    }
    if ("hours_add" in info) {
      date.setTime(date.getTime() + info.hours_add * Date.Util.Interval.Hour);
    }
    if ("day_add" in info) {
      date.setTime(date.getTime() + info.day_add * Date.Util.Interval.Day);
    }
    if ("week_add" in info) {
      date.setTime(date.getTime() + info.week_add * Date.Util.Interval.Week);
    }
    if ("month_add" in info) {
      date.setMonth(date.getMonth() + info.month_add);
    }
    if ("year_add" in info) {
      date.setYear(date.getFullYear() + info.year_add);
    }
    return date;
  };

  Date.parse = function(str, date) {
    var a, p, r, rules, tokens, word_list, _i, _len;
    str = str.toLowerCase();
    word_list = (function() {
      var _i, _len, _ref, _results;
      _ref = str.split(/\s*[,;!?]\s*|\s*\.\s+|\s+/);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        a = _ref[_i];
        if (a.length > 0) {
          _results.push(a);
        }
      }
      return _results;
    })();
    tokens = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = word_list.length; _i < _len; _i++) {
        a = word_list[_i];
        _results.push(to_token(a));
      }
      return _results;
    })();
    tokens = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = tokens.length; _i < _len; _i++) {
        a = tokens[_i];
        if (a !== null) {
          _results.push(a);
        }
      }
      return _results;
    })();
    rules = [];
    while (tokens.length) {
      p = pick(tokens);
      if (p !== null) {
        rules.push(p);
      }
    }
    if (rules.length === 0) {
      return null;
    }
    date = date ? new Date(date) : new Date;
    for (_i = 0, _len = rules.length; _i < _len; _i++) {
      r = rules[_i];
      apply(r.info, date);
    }
    return date;
  };

  Rule = (function() {

    function Rule(classes) {
      this.classes = classes;
      this.length = this.classes.length;
      this.info = {};
    }

    Rule.prototype.match = function(tokens) {
      var cls, k, matched, matches;
      matches = (function() {
        var _i, _len, _ref, _results;
        _ref = this.classes;
        _results = [];
        for (k = _i = 0, _len = _ref.length; _i < _len; k = ++_i) {
          cls = _ref[k];
          if (tokens[k] instanceof cls) {
            _results.push(tokens[k]);
          }
        }
        return _results;
      }).call(this);
      matched = matches.length === this.classes.length;
      if (matched) {
        this.info = this.value(matches);
      }
      return matched;
    };

    Rule.prototype.value = function(tokens) {
      return {};
    };

    return Rule;

  })();

  SingleTokenRule = (function(_super) {

    __extends(SingleTokenRule, _super);

    function SingleTokenRule(cls) {
      SingleTokenRule.__super__.constructor.call(this, [cls]);
    }

    return SingleTokenRule;

  })(Rule);

  NextLastRule = (function(_super) {

    __extends(NextLastRule, _super);

    function NextLastRule(cls, property) {
      this.property = property;
      NextLastRule.__super__.constructor.call(this, [NextLastToken, cls]);
    }

    NextLastRule.prototype.value = function(tokens) {
      var r;
      r = {};
      r[this.property] = tokens[0].value();
      return r;
    };

    return NextLastRule;

  })(Rule);

  WeekdayMonthDayYearRule = (function(_super) {

    __extends(WeekdayMonthDayYearRule, _super);

    function WeekdayMonthDayYearRule() {
      WeekdayMonthDayYearRule.__super__.constructor.call(this, [DayNameToken, MonthNameToken, Number2Token, Number4Token]);
    }

    WeekdayMonthDayYearRule.prototype.value = function(tokens) {
      return {
        month: tokens[1].id(),
        day: tokens[2].value(),
        year: tokens[3].value()
      };
    };

    return WeekdayMonthDayYearRule;

  })(Rule);

  MonthDayYearRule = (function(_super) {

    __extends(MonthDayYearRule, _super);

    function MonthDayYearRule() {
      MonthDayYearRule.__super__.constructor.call(this, [MonthNameToken, Number2Token, Number4Token]);
    }

    MonthDayYearRule.prototype.value = function(tokens) {
      return {
        month: tokens[0].id(),
        day: tokens[1].value(),
        year: tokens[2].value()
      };
    };

    return MonthDayYearRule;

  })(Rule);

  WeekdayMonthDayRule = (function(_super) {

    __extends(WeekdayMonthDayRule, _super);

    function WeekdayMonthDayRule() {
      WeekdayMonthDayRule.__super__.constructor.call(this, [DayNameToken, MonthNameToken, Number2Token]);
    }

    WeekdayMonthDayRule.prototype.value = function(tokens) {
      return {
        month: tokens[1].id(),
        day: tokens[2].value()
      };
    };

    return WeekdayMonthDayRule;

  })(Rule);

  MonthDayRule = (function(_super) {

    __extends(MonthDayRule, _super);

    function MonthDayRule() {
      MonthDayRule.__super__.constructor.call(this, [MonthNameToken, Number2Token]);
    }

    MonthDayRule.prototype.value = function(tokens) {
      return {
        month: tokens[0].id(),
        day: tokens[1].value()
      };
    };

    return MonthDayRule;

  })(Rule);

  DateYYTokenRule = (function(_super) {

    __extends(DateYYTokenRule, _super);

    function DateYYTokenRule() {
      DateYYTokenRule.__super__.constructor.call(this, DateYYToken);
    }

    DateYYTokenRule.prototype.value = function(tokens) {
      return {
        year: tokens[0].year(),
        day: tokens[0].day(),
        month: tokens[0].month()
      };
    };

    return DateYYTokenRule;

  })(SingleTokenRule);

  DateYYYYTokenRule = (function(_super) {

    __extends(DateYYYYTokenRule, _super);

    function DateYYYYTokenRule() {
      DateYYYYTokenRule.__super__.constructor.call(this, DateYYYYToken);
    }

    DateYYYYTokenRule.prototype.value = function(tokens) {
      return {
        year: tokens[0].year(),
        day: tokens[0].day(),
        month: tokens[0].month()
      };
    };

    return DateYYYYTokenRule;

  })(SingleTokenRule);

  DayTokenRule = (function(_super) {

    __extends(DayTokenRule, _super);

    function DayTokenRule() {
      DayTokenRule.__super__.constructor.call(this, DayNameToken);
    }

    DayTokenRule.prototype.value = function(tokens) {
      return {
        next_week_day: tokens[0].id()
      };
    };

    return DayTokenRule;

  })(SingleTokenRule);

  MonthTokenRule = (function(_super) {

    __extends(MonthTokenRule, _super);

    function MonthTokenRule() {
      MonthTokenRule.__super__.constructor.call(this, MonthNameToken);
    }

    MonthTokenRule.prototype.value = function(tokens) {
      return {
        month: tokens[0].id()
      };
    };

    return MonthTokenRule;

  })(SingleTokenRule);

  TomorrowRule = (function(_super) {

    __extends(TomorrowRule, _super);

    function TomorrowRule() {
      TomorrowRule.__super__.constructor.call(this, TomorrowToken);
    }

    TomorrowRule.prototype.value = function(tokens) {
      return {
        day_add: +1
      };
    };

    return TomorrowRule;

  })(SingleTokenRule);

  YesterdayRule = (function(_super) {

    __extends(YesterdayRule, _super);

    function YesterdayRule() {
      YesterdayRule.__super__.constructor.call(this, YesterdayToken);
    }

    YesterdayRule.prototype.value = function(tokens) {
      return {
        day_add: -1
      };
    };

    return YesterdayRule;

  })(SingleTokenRule);

  TodayRule = (function(_super) {

    __extends(TodayRule, _super);

    function TodayRule() {
      TodayRule.__super__.constructor.call(this, TodayToken);
    }

    TodayRule.prototype.value = function(tokens) {
      return {
        day_add: 0
      };
    };

    return TodayRule;

  })(SingleTokenRule);

  NoonRule = (function(_super) {

    __extends(NoonRule, _super);

    function NoonRule() {
      NoonRule.__super__.constructor.call(this, NoonToken);
    }

    NoonRule.prototype.value = function(tokens) {
      return {
        hours: 12,
        minutes: 0,
        seconds: 0
      };
    };

    return NoonRule;

  })(SingleTokenRule);

  LunchRule = (function(_super) {

    __extends(LunchRule, _super);

    function LunchRule() {
      LunchRule.__super__.constructor.call(this, LunchToken);
    }

    LunchRule.prototype.value = function(tokens) {
      return {
        hours: 12,
        minutes: 0,
        seconds: 0
      };
    };

    return LunchRule;

  })(SingleTokenRule);

  MidnightRule = (function(_super) {

    __extends(MidnightRule, _super);

    function MidnightRule() {
      MidnightRule.__super__.constructor.call(this, MidnightToken);
    }

    MidnightRule.prototype.value = function(tokens) {
      return {
        hours: 0,
        minutes: 0,
        seconds: 0
      };
    };

    return MidnightRule;

  })(SingleTokenRule);

  NextLastWeekRule = (function(_super) {

    __extends(NextLastWeekRule, _super);

    function NextLastWeekRule() {
      NextLastWeekRule.__super__.constructor.call(this, WeekToken, "week_add");
    }

    return NextLastWeekRule;

  })(NextLastRule);

  NextLastMonthRule = (function(_super) {

    __extends(NextLastMonthRule, _super);

    function NextLastMonthRule() {
      NextLastMonthRule.__super__.constructor.call(this, MonthToken, "month_add");
    }

    return NextLastMonthRule;

  })(NextLastRule);

  NextLastYearRule = (function(_super) {

    __extends(NextLastYearRule, _super);

    function NextLastYearRule() {
      NextLastYearRule.__super__.constructor.call(this, YearToken, "year_add");
    }

    return NextLastYearRule;

  })(NextLastRule);

  NextLastDayRule = (function(_super) {

    __extends(NextLastDayRule, _super);

    function NextLastDayRule() {
      NextLastDayRule.__super__.constructor.call(this, [NextLastToken, DayNameToken]);
    }

    NextLastDayRule.prototype.value = function(tokens) {
      var r, v;
      r = {};
      v = tokens[0].value();
      r[v < 0 ? "last_week_day" : "next_week_day"] = tokens[1].id();
      return r;
    };

    return NextLastDayRule;

  })(Rule);

  NumberAtRule = (function(_super) {

    __extends(NumberAtRule, _super);

    function NumberAtRule() {
      NumberAtRule.__super__.constructor.call(this, [AtToken, Number2Token]);
    }

    NumberAtRule.prototype.value = function(tokens) {
      return {
        hours: tokens[1].value(),
        minutes: 0,
        seconds: 0
      };
    };

    return NumberAtRule;

  })(Rule);

  NumberPRule = (function(_super) {

    __extends(NumberPRule, _super);

    function NumberPRule() {
      NumberPRule.__super__.constructor.call(this, Number2PToken);
    }

    NumberPRule.prototype.value = function(tokens) {
      return {
        hours: tokens[0].value(),
        minutes: 0,
        seconds: 0,
        pmam: tokens[0].pmam()
      };
    };

    return NumberPRule;

  })(SingleTokenRule);

  TimeRule = (function(_super) {

    __extends(TimeRule, _super);

    function TimeRule() {
      TimeRule.__super__.constructor.call(this, TimeToken);
    }

    TimeRule.prototype.value = function(tokens) {
      return {
        hours: tokens[0].hours(),
        minutes: tokens[0].minutes(),
        seconds: 0
      };
    };

    return TimeRule;

  })(SingleTokenRule);

  TimePRule = (function(_super) {

    __extends(TimePRule, _super);

    function TimePRule() {
      TimePRule.__super__.constructor.call(this, TimePToken);
    }

    TimePRule.prototype.value = function(tokens) {
      return {
        hours: tokens[0].hours(),
        minutes: tokens[0].minutes(),
        seconds: 0,
        pmam: tokens[0].pmam()
      };
    };

    return TimePRule;

  })(SingleTokenRule);

  Rules = [DayTokenRule, MonthTokenRule, TomorrowRule, YesterdayRule, TodayRule, NextLastMonthRule, NextLastYearRule, NextLastDayRule, NextLastWeekRule, NumberAtRule, NumberPRule, NumberPRule, TimeRule, TimePRule, LunchRule, NoonRule, MidnightRule, DateYYTokenRule, DateYYYYTokenRule, MonthDayYearRule, WeekdayMonthDayYearRule, MonthDayRule, WeekdayMonthDayRule];

  Date.Util = {
    Interval: {
      Second: 1000,
      Minute: 60 * 1000,
      Hour: 60 * 60 * 1000,
      Day: 24 * 60 * 60 * 1000,
      Week: 7 * 24 * 60 * 60 * 1000
    },
    Day: {
      Full: ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"],
      Abbrev: ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
    },
    Month: {
      Full: ["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"],
      Abbrev: ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
    }
  };

  AbstractToken = (function() {

    function AbstractToken(regexp) {
      this.regexp = regexp;
    }

    AbstractToken.prototype.use = function(str) {
      this.match = str.match(this.regexp);
      return this.match !== null && this.match[0].length === str.length;
    };

    AbstractToken.prototype.value = function() {
      return this.match[0];
    };

    return AbstractToken;

  })();

  StaticToken = (function(_super) {

    __extends(StaticToken, _super);

    function StaticToken(str) {
      StaticToken.__super__.constructor.call(this, RegExp("" + str));
    }

    return StaticToken;

  })(AbstractToken);

  ListToken = (function(_super) {

    __extends(ListToken, _super);

    function ListToken(list) {
      this.list = list;
      ListToken.__super__.constructor.call(this, this.list.join("|"));
    }

    ListToken.prototype.id = function() {
      return this.list.indexOf(this.match[0].slice(0, 3));
    };

    return ListToken;

  })(StaticToken);

  AbbrevListToken = (function(_super) {

    __extends(AbbrevListToken, _super);

    function AbbrevListToken(list) {
      var d, l, _i, _j, _len, _len1, _ref, _ref1;
      l = [];
      _ref = list.Full;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        d = _ref[_i];
        l.push(d);
      }
      _ref1 = list.Abbrev;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        d = _ref1[_j];
        l.push(d);
      }
      AbbrevListToken.__super__.constructor.call(this, l);
      this.list = list.Abbrev;
    }

    return AbbrevListToken;

  })(ListToken);

  DayNameToken = (function(_super) {

    __extends(DayNameToken, _super);

    function DayNameToken() {
      DayNameToken.__super__.constructor.call(this, Date.Util.Day);
    }

    return DayNameToken;

  })(AbbrevListToken);

  MonthNameToken = (function(_super) {

    __extends(MonthNameToken, _super);

    function MonthNameToken() {
      MonthNameToken.__super__.constructor.call(this, Date.Util.Month);
    }

    return MonthNameToken;

  })(AbbrevListToken);

  AtToken = (function(_super) {

    __extends(AtToken, _super);

    function AtToken() {
      AtToken.__super__.constructor.call(this, "at");
    }

    return AtToken;

  })(StaticToken);

  MonthToken = (function(_super) {

    __extends(MonthToken, _super);

    function MonthToken() {
      MonthToken.__super__.constructor.call(this, "month");
    }

    return MonthToken;

  })(StaticToken);

  WeekToken = (function(_super) {

    __extends(WeekToken, _super);

    function WeekToken() {
      WeekToken.__super__.constructor.call(this, "week");
    }

    return WeekToken;

  })(StaticToken);

  YearToken = (function(_super) {

    __extends(YearToken, _super);

    function YearToken() {
      YearToken.__super__.constructor.call(this, "year");
    }

    return YearToken;

  })(StaticToken);

  NoonToken = (function(_super) {

    __extends(NoonToken, _super);

    function NoonToken() {
      NoonToken.__super__.constructor.call(this, "noon");
    }

    return NoonToken;

  })(StaticToken);

  MidnightToken = (function(_super) {

    __extends(MidnightToken, _super);

    function MidnightToken() {
      MidnightToken.__super__.constructor.call(this, "midnight");
    }

    return MidnightToken;

  })(StaticToken);

  LunchToken = (function(_super) {

    __extends(LunchToken, _super);

    function LunchToken() {
      LunchToken.__super__.constructor.call(this, "lunch");
    }

    return LunchToken;

  })(StaticToken);

  TodayToken = (function(_super) {

    __extends(TodayToken, _super);

    function TodayToken() {
      TodayToken.__super__.constructor.call(this, "today");
    }

    return TodayToken;

  })(StaticToken);

  TomorrowToken = (function(_super) {

    __extends(TomorrowToken, _super);

    function TomorrowToken() {
      TomorrowToken.__super__.constructor.call(this, "tomorrow");
    }

    return TomorrowToken;

  })(StaticToken);

  YesterdayToken = (function(_super) {

    __extends(YesterdayToken, _super);

    function YesterdayToken() {
      YesterdayToken.__super__.constructor.call(this, "yesterday");
    }

    return YesterdayToken;

  })(StaticToken);

  NextToken = (function(_super) {

    __extends(NextToken, _super);

    function NextToken() {
      NextToken.__super__.constructor.call(this, "next");
    }

    return NextToken;

  })(StaticToken);

  LastToken = (function(_super) {

    __extends(LastToken, _super);

    function LastToken() {
      LastToken.__super__.constructor.call(this, "last");
    }

    return LastToken;

  })(StaticToken);

  NextLastToken = (function(_super) {

    __extends(NextLastToken, _super);

    function NextLastToken() {
      NextLastToken.__super__.constructor.call(this, /next|last/);
    }

    NextLastToken.prototype.value = function() {
      if (this.match[0] === "next") {
        return 1;
      } else if (this.match[0] === "last") {
        return -1;
      } else {
        return 0;
      }
    };

    return NextLastToken;

  })(AbstractToken);

  DateYYToken = (function(_super) {

    __extends(DateYYToken, _super);

    function DateYYToken() {
      DateYYToken.__super__.constructor.call(this, /([0-9]{1,2})[.\/]([0-9]{1,2})[.\/]([0-9]{2})/);
    }

    DateYYToken.prototype.use = function(str) {
      return (DateYYToken.__super__.use.call(this, str)) && this.day() <= 31 && this.day() > 0 && this.month() <= 11 && this.month() >= 0;
    };

    DateYYToken.prototype.month = function() {
      return (parseInt(this.match[1])) - 1;
    };

    DateYYToken.prototype.day = function() {
      return parseInt(this.match[2]);
    };

    DateYYToken.prototype.year = function() {
      return 2000 + parseInt(this.match[3]);
    };

    return DateYYToken;

  })(AbstractToken);

  DateYYYYToken = (function(_super) {

    __extends(DateYYYYToken, _super);

    function DateYYYYToken() {
      DateYYYYToken.__super__.constructor.call(this, /([0-9]{1,2})[.\/]([0-9]{1,2})[.\/]([0-9]{4})/);
    }

    DateYYYYToken.prototype.use = function(str) {
      return (DateYYYYToken.__super__.use.call(this, str)) && this.day() <= 31 && this.day() > 0 && this.month() <= 11 && this.month() >= 0;
    };

    DateYYYYToken.prototype.month = function() {
      return (parseInt(this.match[1])) - 1;
    };

    DateYYYYToken.prototype.day = function() {
      return parseInt(this.match[2]);
    };

    DateYYYYToken.prototype.year = function() {
      return parseInt(this.match[3]);
    };

    return DateYYYYToken;

  })(AbstractToken);

  Number2Token = (function(_super) {

    __extends(Number2Token, _super);

    function Number2Token() {
      Number2Token.__super__.constructor.call(this, /[0-9]{1,2}/);
    }

    Number2Token.prototype.value = function() {
      return parseInt(this.match[0]);
    };

    return Number2Token;

  })(AbstractToken);

  Number2PToken = (function(_super) {

    __extends(Number2PToken, _super);

    function Number2PToken() {
      Number2PToken.__super__.constructor.call(this, /([0-9]{1,2})(p|a)m?/);
    }

    Number2PToken.prototype.value = function() {
      return parseInt(this.match[1]);
    };

    Number2PToken.prototype.pmam = function() {
      return this.match[2];
    };

    return Number2PToken;

  })(AbstractToken);

  TimeToken = (function(_super) {

    __extends(TimeToken, _super);

    function TimeToken() {
      TimeToken.__super__.constructor.call(this, /([0-9]{1,2}):([0-9]{2})/);
    }

    TimeToken.prototype.hours = function() {
      return parseInt(this.match[1]);
    };

    TimeToken.prototype.minutes = function() {
      return parseInt(this.match[2]);
    };

    return TimeToken;

  })(AbstractToken);

  TimePToken = (function(_super) {

    __extends(TimePToken, _super);

    function TimePToken() {
      TimePToken.__super__.constructor.call(this, /([0-9]{1,2}):([0-9]{2})(p|a)m?/);
    }

    TimePToken.prototype.hours = function() {
      return parseInt(this.match[1]);
    };

    TimePToken.prototype.minutes = function() {
      return parseInt(this.match[2]);
    };

    TimePToken.prototype.pmam = function() {
      return this.match[3];
    };

    return TimePToken;

  })(AbstractToken);

  Number4Token = (function(_super) {

    __extends(Number4Token, _super);

    function Number4Token() {
      Number4Token.__super__.constructor.call(this, /[0-9]{4}/);
    }

    Number4Token.prototype.value = function() {
      return parseInt(this.match[0]);
    };

    return Number4Token;

  })(AbstractToken);

  to_token = function(word) {
    var Token, t, _i, _len;
    for (_i = 0, _len = Tokens.length; _i < _len; _i++) {
      Token = Tokens[_i];
      t = new Token;
      if (t.use(word)) {
        return t;
      }
    }
    return null;
  };

  Tokens = [DayNameToken, MonthNameToken, AtToken, MonthToken, WeekToken, YearToken, NoonToken, MidnightToken, LunchToken, TodayToken, TomorrowToken, YesterdayToken, NextLastToken, Number2Token, Number2PToken, TimeToken, TimePToken, Number4Token, DateYYToken, DateYYYYToken];

}).call(this);
