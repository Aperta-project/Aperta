`import Ember from 'ember'`

ManuscriptManagerTemplateThumbnailView = Ember.View.extend
  templateName: 'admin/manuscript-manager-templates/thumbnail'
  classNames: ['mmt-thumbnail', 'blue-box']
  classNameBindings: ['destroyState:mmt-thumbnail-destroy']
  canDeleteTemplates: Ember.computed.alias('controller.canDeleteTemplates')

  phaseCount: Ember.computed.alias 'content.phaseTemplates.length'

  destroyState: false

  actions:
    toggleWillDestroyTemplate: ->
      @toggleProperty('destroyState')

`export default ManuscriptManagerTemplateThumbnailView`
