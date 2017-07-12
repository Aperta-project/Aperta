import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['admin-drawer-item'],
  routing: Ember.inject.service('-routing'),
  currentRoute: Ember.computed.alias('routing.currentRouteName')
});
