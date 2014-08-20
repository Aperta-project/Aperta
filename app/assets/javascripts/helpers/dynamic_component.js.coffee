# Idea inspired by: http://discuss.emberjs.com/t/dynamically-render-polymorphic-component/3184/6

Ember.Handlebars.registerBoundHelper 'inlineEdit', (record, context, options) ->
  componentName = "inline-edit-#{record.type}"
  options.hash.bodyPart = record
  options.hash.model = context

  helper = Em.Handlebars.resolveHelper(options.data.view.container, componentName)

  helper.call(this, options)
