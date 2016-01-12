import Ember from 'ember';
import ENV from 'tahi/config/environment';

const debug = function(description, obj) {
  const devOrTest = ENV.environment === 'development' ||
                    ENV.environment === 'test' ||
                    Ember.testing;

  if(devOrTest) {
    console.groupCollapsed(description);
    console.log(Ember.copy(obj, true));
    console.groupEnd();
  }
};


export default Ember.Route.extend({
  restless: Ember.inject.service(),
  notifications: Ember.inject.service(),

  setupController(controller, model) {
    controller.set('model', model);
    if (this.currentUser) {
      // subscribe to user and system channels
      let userChannelName = `private-user@${ this.currentUser.get('id') }`;
      let pusher = this.get('pusher');
      pusher.wire(this, userChannelName, ['created', 'updated', 'destroyed', 'flashMessage']);
      pusher.wire(this, 'system', ['destroyed']);

      this.get('restless').authorize(
        controller,
        '/api/admin/journals/authorization',
        'canViewAdminLinks'
      );

      this.get('restless').authorize(
        controller,
        '/api/user_flows/authorization',
        'canViewFlowManagerLink'
      );
    }
  },

  applicationSerializer: Ember.computed(function() {
    return this.get('container').lookup('serializer:application');
  }),

  actions: {
    willTransition(transition) {
      let currentRouteController = this.controllerFor(
        this.controllerFor('application').get('currentRouteName')
      );

      if (currentRouteController.get('isUploading')) {
        let q = 'You are uploading. Are you sure you want abort uploading?';
        if (confirm(q)) {
          currentRouteController.send('cancelUploads');
        } else {
          transition.abort();
          return;
        }
      }
    },

    error(response, transition) {
      const oldState   = transition.router.oldState;
      const lastRoute  = oldState.handlerInfos.get('lastObject.name');
      const targetName = transition.targetName;
      const prefix     = 'Error in transition';
      let transitionMsg;

      if(oldState) {
        transitionMsg = `${prefix} from ${lastRoute} to #{targetName}`;
      } else {
        transitionMsg = `${prefix} into ${targetName}`;
      }

      this.logError(
        transitionMsg + '\n' + response.message + '\n' + response.stack + '\n'
      );

      transition.abort();
    },

    created(payload) {
      let description = `Pusher: created ${payload.type} ${payload.id}`;
      debug(description);

      if(payload.type === 'notification') {
        this.get('notifications').created(payload);
      } else {
        this.store.fetchById(payload.type, payload.id);
      }
    },

    updated(payload) {
      let record = this.store.getPolymorphic(payload.type, payload.id);
      if (record) {
        record.reload();

        let description = `Pusher: updated ${payload.type} ${payload.id}`;
        debug(description);
      }
    },

    destroyed(payload) {
      let description = `Pusher: destroyed ${payload.type} ${payload.id}`;
      debug(description, payload);

      if(payload.type === 'notification') {
        this.get('notifications').destroyed(payload);
      } else {
        let record = this.store.getPolymorphic(payload.type, payload.id);
        if(record) {
          record.unloadRecord();
        }
      }
    },

    flashMessage(payload) {
      this.flash.displayMessage(payload.messageType, payload.message);
    }
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method to think we have `ember-pusher/bindings` mixed in
    return this.toString();
  }
});
