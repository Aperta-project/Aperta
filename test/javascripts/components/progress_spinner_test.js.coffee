moduleForComponent 'progress-spinner', 'Unit: components/progress-spinner',
  setup: -> setupApp()
  teardown: -> ETahi.reset()

test 'spins', ->
  spinner = @subject()
  equal spinner.state, 'preRender'
  @append()
  equal spinner.state, 'inDOM'
