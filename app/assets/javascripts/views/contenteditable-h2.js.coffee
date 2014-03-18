ETahi.ContenteditableView = Em.View.extend
  tagName: 'h2'
  attributeBindings: ['contenteditable']

  contenteditable: "true"

  focusOut: (e)->
    name = e.currentTarget.innerText
    phase = @.get('phase')

    if phase.get('name') != name
      phase.set('name', name)
      phase.save()
