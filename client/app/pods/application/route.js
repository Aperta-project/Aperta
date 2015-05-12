import Ember from 'ember';
import AnimateElement from 'tahi/mixins/routes/animate-element';
import RESTless from 'tahi/services/rest-less';
import Utils from 'tahi/services/utils';

export default Ember.Route.extend(AnimateElement, {
  setupController: function(controller, model) {
    controller.set('model', model);
    if (this.currentUser) {
      // subscribe to user and system channels
      let userChannelName = `private-user@${ this.currentUser.get('id') }`;
      let pusher = this.get('pusher');
      pusher.wire(this, userChannelName, ["created", "updated"]);
      pusher.wire(this, "system", ["destroyed"]);

      RESTless.authorize(controller, '/api/admin/journals/authorization', 'canViewAdminLinks');
      RESTless.authorize(controller, '/api/user_flows/authorization', 'canViewFlowManagerLink');
    }
  },

  applicationSerializer: Ember.computed(function() {
    return this.get('container').lookup("serializer:application");
  }),

  actions: {
    willTransition(transition) {
      let appController, currentRouteController;
      appController = this.controllerFor('application');
      currentRouteController = this.controllerFor(appController.get('currentRouteName'));
      if (currentRouteController.get('isUploading')) {
        if (confirm('You are uploading. Are you sure you want abort uploading?')) {
          currentRouteController.send('cancelUploads');
        } else {
          transition.abort();
          return;
        }
      }
      return appController.send('hideNavigation');
    },

    error(response, transition) {
      let oldState  = transition.router.oldState;
      let lastRoute = oldState.handlerInfos.get('lastObject.name');
      let transitionMsg;

      if(oldState) {
        transitionMsg = `Error in transition from ${lastRoute} to #{transition.targetName}`;
      } else {
        transitionMsg = `Error in transition into ${transition.targetName}`;
      }

      this.logError(transitionMsg + '\n' + response.message + '\n' + response.stack + '\n');

      transition.abort();
    },

    closeOverlay() {
      this.flash.clearAllMessages();
      this.disconnectOutlet({
        outlet: 'overlay',
        parentView: 'application'
      });
    },

    closeAction() {
      this.send('closeOverlay');
    },

    editableDidChange() { return null; },

    feedback() {
      this.render('overlays/feedback', {
        into: 'application',
        outlet: 'overlay',
        controller: 'overlays/feedback'
      });
    },

    created(payload) {
      let description = "Pusher: created";
      Utils.debug(description, payload);
      this.store.pushPayload(payload);
    },

    updated(payload) {
      let description = "Pusher: updated";
      Utils.debug(description, payload);
      this.store.pushPayload(payload);
    },

    destroyed(payload) {
      let description = "Pusher: destroyed";
      Utils.debug(description, payload);
      let type = this.get('applicationSerializer').typeForRoot(payload.type);
      payload.ids.forEach((id) => {
        let record;
        if (type === "task")
          record = this.store.findTask(id);
        else
          record = this.store.getById(type, id);
        if (record)
          record.unloadRecord();
      });
    }
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method to think we have `ember-pusher/bindings` mixed in
    return this.toString()
  }
});
