import Ember from 'ember';

export default {
  name: 'flashMessages',

  initialize(application) {
    application.inject('route', 'flash', 'service:flash');
    application.inject('controller', 'flash', 'service:flash');
    application.inject('component:flashMessages', 'flash', 'service:flash');

    Ember.Route.reopen({
      _teardownFlashMessages: Ember.on('deactivate', function() {
        this.flash.clearAllRouteLevelMessages();
      })
    });
  }
};
