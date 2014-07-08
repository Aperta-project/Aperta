ETahi.IndexController = Ember.ObjectController.extend
  needs: ['application']

  currentUser: Ember.computed.alias 'controllers.application.currentUser'

  hasSubmissions: Ember.computed.notEmpty('model.submissions')
