import Ember from 'ember';
import Flash from 'tahi/services/flash';

export default {
  name: 'flashMessages',

  initialize: function(container, application) {
    container.register('flashMessages:main', Flash);
    application.inject('route', 'flash', 'flashMessages:main');
    application.inject('controller', 'flash', 'flashMessages:main');
    application.inject('component:flashMessages', 'flash', 'flashMessages:main');

    Ember.Route.reopen({
      enter: function() {
        this._super.apply(this, arguments);

        var routeName = this.get('routeName');
        var target    = this.get('router.router.activeTransition.targetName');

        if (routeName !== 'loading' && routeName === target) {
          this.flash.clearMessages();
        }
      }
    });
  }
};
