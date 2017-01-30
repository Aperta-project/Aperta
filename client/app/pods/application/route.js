import Ember from 'ember';
import ENV from 'tahi/config/environment';

const { getOwner } = Ember;

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
  fullStory: Ember.inject.service(),

  beforeModel() {
    Ember.assert('Application name is required for proper display', window.appName);
    this.store.findAll('journal').then( (journals) => {
      let controller = this.controllerFor('application');
      controller.set('journals', journals);
      controller.setCanViewPaperTracker();
    });
  },

  setupController(controller, model) {
    controller.set('model', model);
    if (this.currentUser) {
      // subscribe to user and system channels
      const userChannelName = `private-user@${ this.currentUser.get('id') }`;
      const pusher = this.get('pusher');

      pusher.wire(this, 'system', ['destroyed']);
      pusher.wire(
        this,
        userChannelName,
        ['created', 'updated', 'destroyed', 'flashMessage']
      );

      this.get('restless').authorize(
        controller,
        '/api/admin/journals/authorization',
        'canViewAdminLinks'
      );

      this.get('fullStory').identify(this.currentUser);
    }
  },

  applicationSerializer: Ember.computed(function() {
    return getOwner(this).lookup('serializer:application');
  }),

  assignWindowLocation(location) {
    window.location.assign(location);
  },

  actions: {
    willTransition(transition) {
      let currentRouteController = this.controllerFor(
        this.controllerFor('application').get('currentRouteName')
      );

      if (currentRouteController.get('isUploading')) {
        let q = 'You are uploading. Are you sure you want abort uploading?';
        if (window.confirm(q)) {
          currentRouteController.send('cancelUploads');
        } else {
          transition.abort();
          return;
        }
      }
    },

    error(response, transition) {
      const oldState   = transition.router.oldState;
      const targetName = transition.targetName;
      const prefix     = 'Error in transition';
      let transitionMsg;

      if(oldState) {
        let lastRoute  = oldState.handlerInfos.get('lastObject.name');
        transitionMsg = `${prefix} from ${lastRoute} to ${targetName}`;
      } else {
        transitionMsg = `${prefix} into ${targetName}`;
      }

      this.logError(
        transitionMsg + '\n' + response.message + '\n' + response.stack + '\n'
      );

      transition.abort();
    },

    created(payload) {
      debug(`Pusher: created ${payload.type} ${payload.id}`);

      if(payload.type === 'notification') {
        this.send('notificationAction', 'created', payload);
        return;
      }

      this.store.findRecord(payload.type, payload.id, { reload: true });
    },

    updated(payload) {
      const record = this.store.getPolymorphic(payload.type, payload.id);
      if (record && !record.get('isDeleted')) {
        record.reload();
        debug(`Pusher: updated ${payload.type} ${payload.id}`);
      }
    },

    destroyed(payload) {
      debug(`Pusher: destroyed ${payload.type} ${payload.id}`, payload);

      if(payload.type === 'notification') {
        this.send('notificationAction', 'destroyed', payload);
        return;
      }

      const record = this.store.getPolymorphic(payload.type, payload.id);
      if(record) {
        record.unloadRecord();
      }
    },

    notificationAction(action, payload) {
      this.get('notifications')[action](payload);
    },

    flashMessage(payload) {
      this.flash.displayRouteLevelMessage(payload.messageType, payload.message);
    },

    signOut() {
      this.get('fullStory').clearSession();
      this.assignWindowLocation('/users/sign_out');
    }
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method
    // to think we have `ember-pusher/bindings` mixed in
    return this.toString();
  }
});
