import Ember from 'ember';

export default Ember.Route.extend({
  restless: Ember.inject.service('restless'),

  handleUnauthorizedRequest(transition) {
    transition.abort();
    this.transitionTo('dashboard').then(()=> {
      this.flash.displayMessage('error', "You don't have access to that content");
    });
  },

  setFlagViewManuscriptManager(controller, model){
    if(!this.currentUser) { return; }
    const url = `/api/papers/${model.get('id')}/manuscript_manager`;
    this.get('restless').authorize(controller, url, 'canViewManuscriptManager');
  },

  actions: {
    error(response, transition) {
      console.log(response);
      switch (response.status) {
        case 403:
          this.handleUnauthorizedRequest(transition);
      }
      console.log('Error in transition to ' + transition.targetName);
      return true;
    },
    _pusherEventsId() {
      // needed for the `wire` and `unwire` method to think we have `ember-pusher/bindings` mixed in
      return this.toString();
    }
  }
});
