describe 'GraphiteUrl', ->
  g = null

  beforeEach ->
    g = new GraphiteUrl "http://example.com/"

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
