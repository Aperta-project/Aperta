moduleForComponent 'show-if-parent', 'Component: show-if-parent'

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
  ok !$component.find('p').length, 'setting the prop to false is correctly observed.'

