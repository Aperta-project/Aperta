ETahi.ManuscriptManagerTemplateThumbnailView = Em.View.extend
  templateName: 'manuscript_manager_template/thumbnail'
  classNames: ['template-thumbnail', 'blue-box']
  classNameBindings: ['destroyState:template-thumbnail-destroy']

  destroyState: false

  actions:
    toggleWillDestroyTemplate: ->
      @toggleProperty('destroyState')

