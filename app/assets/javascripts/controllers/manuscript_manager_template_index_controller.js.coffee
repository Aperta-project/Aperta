ETahi.ManuscriptManagerTemplateIndexController = Ember.ArrayController.extend
  actions:
    addTemplate: ->
      @transitionToRoute('manuscript_manager_template.new')
