class GraphiteUrl
  constructor: (base, attrs = {}) ->
    @base = base
    @attrs = attrs
    @targets = []

  attr: (k, v) ->
    @attrs[k] = v

  target: (target) ->
    @targets.push if typeof(target) == "function" then target() else target

  f: (name, info, args...) -> GraphiteUrl.func(name, info, args...)

  s: (string) ->
    s = new String(string)
    s.seriesList = true
    s

  render: ->
    @base + '?' +
      ("#{k}=#{v}" for k, v of @attrs).join('&') + '&' +
      ("target=#{t}" for t in @targets).join('&')

  # go through args, flattening arrays and executing funcs along the way
  resolve_arg = (arg, result) ->
    if arg instanceof Array
      for a in arg
        resolve_arg a, result
    else if typeof(arg) == "function"
      resolve_arg arg(), result
    else if arg.seriesList == true
      result.push arg
    else
      # TODO: escape any quotes in arg
      result.push "'#{arg}'"

  @func: (name, args...) ->
    flattened_args = []
    for a in args
      resolve_arg a, flattened_args
    "#{name}(#{flattened_args.join(',')})"

  # Add graphite functions to the prototype. Some function args must
  # be delivered as strings to graphite, so we also annotate which ones
  # those are so we can serialize them correctly.
  functions = [
    'alias'
    'aliasByNode'
    'aliasSub'
    'alpha'
    'areaBetween'
    'asPercent'
    'averageAbove'
    'averageBelow'
    'averageSeries'
    'averageSeriesWithWildcards'
    'cactiStyle'
    'color'
    'constantLine'
    'cumulative'
    'currentAbove'
    'currentBelow'
    'dashed'
    'derivative'
    'diffSeries'
    'divideSeries'
    'drawAsInfinite'
    'events'
    'exclude'
    'groupByNode'
    'highestAverage'
    'highestCurrent'
    'highestMax'
    'hitcount'
    'holtWintersAberration'
    'holtWintersConfidenceBands'
    'holtWintersForecast'
    'integral'
    'keepLastValue'
    'legendValue'
    'limit'
    'lineWidth'
    'logarithm'
    'lowestAverage'
    'lowestCurrent'
    'maxSeries'
    'maximumAbove'
    'maximumBelow'
    'minSeries'
    'minimumAbove'
    'mostDeviant'
    'movingAverage'
    'movingMedian'
    'multiplySeries'
    'nPercentile'
    'nonNegativeDerivative'
    'offset'
    'randomWalkFunction'
    'rangeOfSeries'
    'removeAbovePercentile'
    'removeAboveValue'
    'removeBelowPercentile'
    'removeBelowValue'
    'scale'
    'secondYAxis'
    'sinFunction'
    'smartSummarize'
    'sortByMaxima'
    'sortByMinima'
    'stacked'
    'stdev'
    'substr'
    'sumSeries'
    'sumSeriesWithWildcards'
    'summarize'
    'threshold'
    'timeFunction'
    'timeShift'
  ]
  for fname in functions
    do (fname) ->
      GraphiteUrl::[fname] = (args...) -> 
        GraphiteUrl.func(fname, args...)
