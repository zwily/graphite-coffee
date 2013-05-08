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
    g = new GraphiteUrl "http://example.com/"

    g.target ->
      g.alias g.s('series'), 'my series'

    url = g.render()

    expect(url).toBe('http://example.com/?&target=alias(series,\'my series\')')
