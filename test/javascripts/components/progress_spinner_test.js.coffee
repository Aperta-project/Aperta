moduleForComponent 'progress-spinner', 'Unit: components/progress-spinner',
  setup: -> setupApp()

test 'spins', ->
  spinner = @subject()
  equal spinner._state, 'preRender'
  @append()
  equal spinner._state, 'inDOM'
