import Ember from 'ember';
import Flash from 'tahi/services/flash';

export default {
  name: 'flashMessages',

  initialize(registry, application) {
    application.register('flashMessages:main', Flash);
    application.inject('route', 'flash', 'flashMessages:main');
    application.inject('controller', 'flash', 'flashMessages:main');
    application.inject('component:flashMessages', 'flash', 'flashMessages:main');

    Ember.Route.reopen({
      _teardownFlashMessages: function() {
        this.flash.clearAllMessages();
      }.on('deactivate')
    });
  }
};
