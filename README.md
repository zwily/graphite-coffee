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
    g.alias ->
      g.divideSeries ->
        g.diffSeries _capacity, _load
      , _capacity
    , 'overprovisioning %'
 
url = g.render()
```

