moduleForComponent 'show-if-content', 'Component: show-if-content'

test 'renders based on the set parent view prop', ->
  fakeParent = Ember.Object.create 
    foo: true
  component = @subject(
    prop: 'foo'
    parentView: fakeParent
    template: Ember.Handlebars.compile("<p>Shown</p>")
  )
  $component = this.append()
  ok $component.find('p').length, 'the content is shown when the prop is true'
  Ember.run ->
    fakeParent.set('foo', false)
  debugger
  ok !$component.find('p').length, 'setting the prop to false is correctly observed.'

