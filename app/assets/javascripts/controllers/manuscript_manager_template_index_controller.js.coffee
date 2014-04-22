ETahi.ManuscriptManagerTemplateIndexController = Ember.ArrayController.extend
  needs: ['manuscriptManagerTemplate']
  template: Ember.computed.alias("controllers.manuscriptManagerTemplate")

  actions:
    addTemplate: ->
      paperTypes = @get('template.paperTypes')
      newTemplate = ETahi.ManuscriptManagerTemplate.create(
        name: "New Template"
        paper_type: paperTypes.get('firstObject')
        template:
          phases: [
            name: "New Phase"
            task_types: []
          ]
      )
      @get('template.model').pushObject(newTemplate)
      false
