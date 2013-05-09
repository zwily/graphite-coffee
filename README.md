# Graphite-Coffee

graphite-coffee is a small library written in CoffeeScript that makes it
slightly easier to programatically generate Graphite URLs:

```coffee
g =  new GraphiteUrl "https://graphite.example.com/render/",
  title: 'Cluster Overprovisioning'
  width: 1000
  from: '-1day'
  until: 'now'
  bgcolor: 'FFFFFF'
  fgcolor: '000000'
  yMin: 0
  tz: 'America/Denver'
  height: 400
 
clusters = [ '1', '1_3', '2_14', '3', '4', '5', '6', '7_11', '8', '9_10', '12_13' ]
_load =
  g.sumSeries ->
    (g.multiplySeries(g.s("clusters.app_cluster.#{c}.cpu"), g.s("clusters.app_cluster.#{c}.instances")) for c in clusters)
 
_capacity =
  g.sumSeries g.s("clusters.app_cluster.*.instances")
 
g.target ->
  g.cactiStyle ->
    g.alias 'overprovisioning %', ->
      g.divideSeries ->
        g.diffSeries _capacity, _load
      , _capacity
 
url = g.render()
```

## Usage

Initialize an instance of GraphiteUrl with the URL to your graphite
installation. You can also pass some URL options:

```coffee
g = new GraphiteUrl "http://graphite.example.com/render/",
  title: "My Graphite Graph"
```

Add or change attributes with `attr`:

```coffee
g.attr 'width', 600
g.attr 'height', 300
```

Add a new target, or line on your graph, with `target`:

```coffee
g.target g.s('path.to.series.blah')
```

SeriesLists (like `path.to.series.blah` above) must be wrapped in `s`.

Apply Graphite functions to your data:

```coffee
g.target ->
  g.dashed -> # makes this series a dashed line
    g.sumSeries g.s('series1'), g.s('series2')
```

(Read about all available functions
[here](http://graphite.readthedocs.org/en/1.0/functions.html).)

For functions that take non-SeriesLists arguments, any SeriesLists
provided will be pulled to the front of the argument list. What that
means is that these two examples both work, the second (hopefully) being
more readable:

```coffee
g.target ->
  g.alias ->
    g.lineWidth ->
      g.sumSeries ->
        [ g.s('series1'), s.g('series2') ]
    , 2
  , 'Summed Series'

g.target ->
  g.alias 'Summed Series', ->
    g.lineWidth 2, ->
      g.sumSeries ->
        [ g.s('series1'), g.s('series2') ]
```

Reuse composed SeriesLists to DRY things up:

```coffee
_load =
  g.sumSeries ->
    (g.multiplySeries(g.s("clusters.app_cluster.#{c}.cpu"), g.s("clusters.app_cluster.#{c}.instances")) for c in [1..10])
 
_capacity =
  g.sumSeries g.s("clusters.app_cluster.*.instances")
 
g.target ->
  g.cactiStyle ->
    g.alias 'overprovisioning %', ->
      g.divideSeries ->
        g.diffSeries _capacity, _load
      , _capacity
 
```

When you're done adding your targets, render the url with `render`:

```coffee
url = g.render()
```

## Questions

### Will it work in JavaScript?

Sure, but the intention was to create a pseudo-DSL for describing
Graphite graphs, and I think you lose some of that with all the
parentheses and `function`s that will be everywhere.
