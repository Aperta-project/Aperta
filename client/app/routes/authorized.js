import Ember from 'ember';

export default Ember.Route.extend({
  can: Ember.inject.service('can'),
  restless: Ember.inject.service('restless'),

  handleUnauthorizedRequest(transition, error) {
    let errorMessage = error || "You don't have access to that content";
    transition.abort();
    this.transitionTo('dashboard').then(()=> {
      this.flash.displayRouteLevelMessage('error', errorMessage);
    });
  },

  actions: {
    error(response, transition) {
      if (!response) {
        this.handleUnauthorizedRequest(transition);
      }
      if (Ember.isArray(response.errors)) {
        let status = response.errors[0].status;
        // use == instead of === to coerce "404" into 404
        if ( status == 404 || status == 403 ) {
          let errorMsg = response.errors[0].detail;
          this.handleUnauthorizedRequest(transition, errorMsg);
        }
      } else {
        switch (response.status) {
          case 403:
            this.handleUnauthorizedRequest(transition);
        }
      }
      return true;
    },
    _pusherEventsId() {
      // needed for the `wire` and `unwire` method to think we have `ember-pusher/bindings` mixed in
      return this.toString();
    }
  }
});
