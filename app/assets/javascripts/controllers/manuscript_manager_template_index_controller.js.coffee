ETahi.ManuscriptManagerTemplateIndexController = Ember.ArrayController.extend
  canDeleteTemplates: Ember.computed.gt('model.length', 1)

  actions:
    addTemplate: ->
      console.log("addTemplate")
      @transitionToRoute('manuscript_manager_template.new')

    destroyTemplate: (template) ->
      console.log("destroyTemplate")
      if @get('canDeleteTemplates')
        template.destroyRecord().then =>
          @get('model').removeObject(template)
