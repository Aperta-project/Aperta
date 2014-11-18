ETahi.ManuscriptManagerTemplateThumbnailView = Em.View.extend
  templateName: 'manuscript_manager_template/thumbnail'
  classNames: ['mmt-thumbnail', 'blue-box']
  classNameBindings: ['destroyState:mmt-thumbnail-destroy']
  canDeleteTemplates: Ember.computed.alias('controller.canDeleteTemplates')

  phaseCount: Em.computed.alias 'content.phaseTemplates.length'

  destroyState: false

  actions:
    toggleWillDestroyTemplate: ->
      @toggleProperty('destroyState')

