ETahi.IndexController = Ember.ObjectController.extend
  currentUser:(-> Tahi.currentUser).property()
  hasSubmissions: Ember.computed.notEmpty('model.submissions')
  hasAssignedTasks: Ember.computed.notEmpty('model.assignedTasks')
