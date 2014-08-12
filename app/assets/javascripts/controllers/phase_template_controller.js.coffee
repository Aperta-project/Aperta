ETahi.PhaseTemplateController = Em.ObjectController.extend
  nextPosition: (->
    @get('position') + 1
  ).property('position')

