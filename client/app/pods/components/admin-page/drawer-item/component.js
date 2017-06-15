import Ember from 'ember';

export default Ember.Component.extend({
  routing: Ember.inject.service('-routing'),
  classNames: ['admin-drawer-item'],

  currentRoute: Ember.computed.alias('routing.currentRouteName'),
});
