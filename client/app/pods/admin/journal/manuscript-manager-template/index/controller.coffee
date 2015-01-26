`import Ember from 'ember'`

ManuscriptManagerTemplateIndexController = Ember.ArrayController.extend
  canDeleteTemplates: Ember.computed.gt('model.length', 1)

  actions:
    addTemplate: ->
      @transitionToRoute('admin.journal.manuscript_manager_template.new')

    destroyTemplate: (template) ->
      if @get('canDeleteTemplates')
        template.destroyRecord().then =>
          @get('model').removeObject(template)

`export default ManuscriptManagerTemplateIndexController`
