ETahi.IndexController = Ember.ObjectController.extend
  needs: ['application']

  currentUser: Ember.computed.alias 'controllers.application.currentUser'

  hasPapers: Ember.computed.notEmpty('model.papers')
