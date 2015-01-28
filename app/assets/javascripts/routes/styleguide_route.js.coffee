ETahi.StyleguideRoute = Ember.Route.extend(
  setupController: (controller, model) ->
    uploads = [
      {
        id: 1,
        title: 'Learn Ember.js',
        isCompleted: true
      },
      {
        id: 2,
        title: '...',
        isCompleted: false
      },
      {
        id: 3,
        title: 'Profit!',
        isCompleted: false
      }
    ]

    controller.set('uploads', uploads)
)
#
#
# setupController: (controller, model) ->
#   controller.set('model', model)
#   controller.set('journal', @modelFor('journal'))
