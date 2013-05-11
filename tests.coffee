describe 'Graphite', ->
  g = null

  beforeEach ->
    g = new Graphite "http://example.com/"

  it 'renders a url', ->
    g.target ->
      g.sumSeries g.s('series1'), g.s('series2')

    url = g.render()

    expect(url).toBe('http://example.com/?&target=sumSeries(series1,series2)')

  it 'expands array arguments', ->
    g.target ->
      g.sumSeries [ g.s('series1'), g.s('series2') ]

    url = g.render()

    expect(url).toBe('http://example.com/?&target=sumSeries(series1,series2)')

  it 'stringifies string arguments', ->
    g.target ->
      g.alias g.s('series'), 'my series'

    url = g.render()

    expect(url).toBe('http://example.com/?&target=alias(series,\'my series\')')

  it 'relocates serieslists to the front of arguments', ->
    g.target ->
      g.alias "my series", ->
        g.s('series')

    url = g.render()

    expect(url).toBe('http://example.com/?&target=alias(series,\'my series\')')

  it 'relocates seriesLists to the front that are embedded in other calls', ->
    g.target ->
      g.alias "my sum", ->
        g.sumSeries g.s('series1'), g.s('series2')

    url = g.render()

    expect(url).toBe('http://example.com/?&target=alias(sumSeries(series1,series2),\'my sum\')')

  it 'correctly stringifies integer arguments', ->
    g.target ->
      g.movingAverage g.s('series'), 50

    url = g.render()

    expect(url).toBe('http://example.com/?&target=movingAverage(series,50)')

  it 'correctly relocates integer arguments', ->
    g.target ->
      g.movingAverage 50, ->
        g.sumSeries g.s('series1'), g.s('series2')

    url = g.render()

    expect(url).toBe('http://example.com/?&target=movingAverage(sumSeries(series1,series2),50)')

  it 'handles simple method-style calls', ->
    g.target ->
      g.s('series').alias("my series")

    url = g.render()

    expect(url).toBe('http://example.com/?&target=alias(series,\'my series\')')

  it 'handles multiple method-style calls', ->
    g.target ->
      g.divideSeries(g.diffSeries(g.s('series1'), g.s('series2')), g.s('series'))
      .alias('some ratio')
      .cactiStyle()

    url = g.render()

    expect(url).toBe('http://example.com/?&target=cactiStyle(alias(divideSeries(diffSeries(series1,series2),series),\'some ratio\'))')

  it 'should render the example from README.md', ->
    g =  new Graphite "https://graphite.example.com/render/",
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
      g.divideSeries(g.diffSeries(_capacity, _load), _capacity)
      .alias('overprovisioning %')
      .cactiStyle()

    url = g.render()

    realUrl = "https://graphite.example.com/render/?title=Cluster Overprovisioning&" +
      "width=1000&from=-1day&until=now&bgcolor=FFFFFF&fgcolor=000000&yMin=0&" +
      "tz=America/Denver&height=400&" +
      "target=cactiStyle(" +
        "alias(" +
          "divideSeries(" +
            "diffSeries(" +
              "sumSeries(clusters.app_cluster.*.instances)," +
              "sumSeries(" +
                "multiplySeries(clusters.app_cluster.1.cpu,clusters.app_cluster.1.instances)," +
                "multiplySeries(clusters.app_cluster.1_3.cpu,clusters.app_cluster.1_3.instances)," +
                "multiplySeries(clusters.app_cluster.2_14.cpu,clusters.app_cluster.2_14.instances)," +
                "multiplySeries(clusters.app_cluster.3.cpu,clusters.app_cluster.3.instances)," +
                "multiplySeries(clusters.app_cluster.4.cpu,clusters.app_cluster.4.instances)," +
                "multiplySeries(clusters.app_cluster.5.cpu,clusters.app_cluster.5.instances)," +
                "multiplySeries(clusters.app_cluster.6.cpu,clusters.app_cluster.6.instances)," +
                "multiplySeries(clusters.app_cluster.7_11.cpu,clusters.app_cluster.7_11.instances)," +
                "multiplySeries(clusters.app_cluster.8.cpu,clusters.app_cluster.8.instances)," +
                "multiplySeries(clusters.app_cluster.9_10.cpu,clusters.app_cluster.9_10.instances)," +
                "multiplySeries(clusters.app_cluster.12_13.cpu,clusters.app_cluster.12_13.instances)" +
              ")" +
            ")," +
            "sumSeries(clusters.app_cluster.*.instances)" +
          ")," +
          "'overprovisioning %'))"

    expect(url).toBe(realUrl)

