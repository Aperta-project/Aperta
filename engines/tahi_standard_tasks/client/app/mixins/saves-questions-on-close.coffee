`import Ember from 'ember'`

SavesQuestionsOnClose = Ember.Mixin.create
  onClose: "saveAndClose"

  actions:
    saveAndClose: ->
      records = @get('model.questions').map (q) ->
        if q.get('isNew') or q.get('isDirty')
           q.save()
      Ember.RSVP.all(records).then =>
        @get('model').save().then =>
          @send('closeOverlay')

`export default SavesQuestionsOnClose`
