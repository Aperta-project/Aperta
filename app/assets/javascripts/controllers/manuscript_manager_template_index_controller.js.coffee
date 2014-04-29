ETahi.ManuscriptManagerTemplateIndexController = Ember.ArrayController.extend
  actions:
    addTemplate: ->
      @transitionToRoute('manuscript_manager_template.new')

    destroyTemplate: (template) ->
      template.destroyRecord().then =>
        @get('model').removeObject(template)
