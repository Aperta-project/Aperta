import Ember from 'ember';
import DiscussionsNewRouteMixin from 'tahi/mixins/discussions/new/route';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend(DiscussionsNewRouteMixin, {
  // required to generate route paths:
  subRouteName: 'index',
  can: Ember.inject.service('can'),

  beforeModel(transition){
    this.get('can').can('start_discussion', this.modelFor('paper')).then( (value)=> {
      if (!value){
        return this.handleUnauthorizedRequest(transition);
      }
    })
  },
});
