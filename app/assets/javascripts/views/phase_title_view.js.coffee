ETahi.ColumnTitleView = Em.View.extend
  classNames: ['column-title']
  classNameBindings: ['active']
  active: false

  focusIn: (e)->
    @set('active', true)

  actions:
    save: ->
      @set('active', false)
      name = @.$('h2').get(0).innerText
      phase = @.get('phase')

      if phase.get('name') != name
        phase.set('name', name)
        phase.save()

    cancel: ->
      @set('active', false)
      @get('phase').rollback()
