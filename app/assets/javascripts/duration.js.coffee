$ ->
  $.fn.parseDuration = (t) ->
    duration = moment.duration(0)
    t = t.replace(/^\s+|\s+$/g, '')
    tokens = _.flatten([ t.toLowerCase().replace(/[^0-9a-z]/,'').split(/\b/), '' ])
    _.each tokens, (t, i) ->
      if q
        if t.match(/^da?y?s?/)
          duration.add(q, 'days')
          q = null
        else if t.match(/^mon?t?h?s?/)
          # Moment.js defines a month as 30 days. Clinically we'd rather
          # have 34 days to have some buffer room.
          duration.add(q, 'months').add('4', 'days')
          q = null
        else if t.match(/^w?e?e?k?s?/)
          duration.add(q, 'weeks')
          q = null
      else
        q = _.parseInt(t) if _.parseInt(t)