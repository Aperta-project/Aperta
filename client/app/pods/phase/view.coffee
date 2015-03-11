`import Ember from 'ember'`
`import DragNDrop from 'tahi/services/drag-n-drop'`

PhaseView = Ember.View.extend DragNDrop.DroppableMixin,
  classNames: ['column']
  lastDraggedOverTask: null

  nextPosition: (->
    @get('controller.model.position') + 1
  ).property('controller.model.position')

  didInsertElement: ->
    controller = @get('controller')
    store = @get('controller.store')
    phaseId = @get('controller.model.id')
    @$('.sortable').sortable
      connectWith: '.sortable'
      update: (event, ui) ->
        updatedOrder = {}

        senderPhaseId = phaseId
        receiverPhaseId = ui.item.parent().data('phase-id') + ''
        console.log senderPhaseId
        console.log receiverPhaseId

        if senderPhaseId isnt receiverPhaseId
          controller.send('changePhaseForTask', ui.item.find('.card-content').data('id'), receiverPhaseId)

        $(this).find('.card-content').each (index) ->
          updatedOrder[$(this).data('id')] = index + 1

        controller.send('updateSortOrder', updatedOrder)

`export default PhaseView`
