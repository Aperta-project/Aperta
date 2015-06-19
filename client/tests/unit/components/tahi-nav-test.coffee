`import { test, moduleForComponent } from 'ember-qunit'`

moduleForComponent 'tahi-nav', 'TahiNavComponent', {
  # specify the other units that are required for this test
  # needs: ['component:foo', 'helper:bar']
}

test 'it renders', ->
  expect 2

  # creates the component instance
  component = @subject()
  equal component._state, 'preRender'

  # appends the component to the page
  @render()
  equal component._state, 'inDOM'
