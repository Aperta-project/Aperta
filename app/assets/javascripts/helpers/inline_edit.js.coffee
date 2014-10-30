# Idea inspired by: http://discuss.emberjs.com/t/dynamically-render-polymorphic-component/3184/6

Ember.Handlebars.registerBoundHelper 'inlineEdit', (record, allUsers, participants, options) ->
  componentName = "inline-edit-#{record.type}"
  # The following cannot be passed in as options because they are simply stored
  # on the options hash as strings, not objects. So we pass them in as
  # arguments and then set them on options.hash.
  options.hash.bodyPart = record
  options.hash.allUsers = allUsers
  options.hash.overlayParticipants = participants

  helper = Em.Handlebars.resolveHelper(options.data.view.container, componentName)

  helper.call(this, options)
