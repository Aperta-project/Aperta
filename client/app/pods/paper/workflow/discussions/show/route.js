import Ember from 'ember';
import DiscussionsShowRouteMixin from 'tahi/mixins/discussions/show/route';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend(DiscussionsShowRouteMixin, {
  // required to generate route paths:
  subRouteName: 'workflow',
  can: Ember.inject.service('can'),

  afterModel(topic, transition){
    return this.get('can').can('view', topic).then( (value)=> {
      if (!value){
        return this.handleUnauthorizedRequest(transition);
      }
      this.setModelChannel(topic);
    });
  },
});
