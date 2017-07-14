import Ember from 'ember';

export default Ember.Route.extend({
  redirect(params) {
    this.transitionTo('admin.journals.workflows', params);
  }

});
