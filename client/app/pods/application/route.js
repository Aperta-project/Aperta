import Ember from 'ember';
import AnimateOverlay from 'tahi/mixins/animate-overlay';
import Utils from 'tahi/services/utils';

export default Ember.Route.extend(AnimateOverlay, {
  restless: Ember.inject.service('restless'),

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

  cleanupAncillaryViews() {
    this.controllerFor('application').send('hideNavigation');

    this.animateOverlayOut().then(()=> {
      this.controllerFor('application').set('showOverlay', false);
    });
  },

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

      this.cleanupAncillaryViews();
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

    openOverlay(options) {
      Ember.assert(
        'You must pass a template name to `openOverlay`',
        options.template
      );
      if(Ember.isEmpty(options.into))   { options.into   = 'application'; }
      if(Ember.isEmpty(options.outlet)) { options.outlet = 'overlay'; }

      this.controllerFor('application').set('showOverlay', true);
      this.render(options.template, options);
    },

    closeOverlay() {
      this.flash.clearAllMessages();
      this.cleanupAncillaryViews();
    },

    closeAction() {
      this.send('closeOverlay');
    },

    feedback() {
      this.controllerFor('overlays/feedback').set('feedbackSubmitted', false);

      this.send('openOverlay', {
        template: 'overlays/feedback',
        controller: 'overlays/feedback'
      });
    },

    created(payload) {
      let description = 'Pusher: created';
      Utils.debug(description, payload);
      this.store.pushPayload(payload);
    },

    updated(payload) {
      let description = 'Pusher: updated';
      Utils.debug(description, payload);
      this.store.pushPayload(payload);
    },

    destroyed(payload) {
      let description = 'Pusher: destroyed';
      Utils.debug(description, payload);
      let type = this.get('applicationSerializer').modelNameFromPayloadKey(payload.type);
      payload.ids.forEach((id) => {
        let record;
        if (type === 'task') {
          record = this.store.findTask(id);
        } else {
          record = this.store.getById(type, id);
        }
        if (record) {
          record.unloadRecord();
        }
      });
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
