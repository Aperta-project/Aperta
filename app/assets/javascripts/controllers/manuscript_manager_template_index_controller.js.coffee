ETahi.ManuscriptManagerTemplateIndexController = Ember.ArrayController.extend
  canDeleteTemplates: Ember.computed.gt('model.length', 1)

  actions:
    addTemplate: ->
      @transitionToRoute('manuscript_manager_template.new')

    destroyTemplate: (template) ->
      if @get('canDeleteTemplates')
        template.destroyRecord().then =>
          @get('model').removeObject(template)
