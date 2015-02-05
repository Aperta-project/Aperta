import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'img',
  attributeBindings: ['alt', 'src', 'toggle', 'title'],
  classNames: ['user-thumbnail'],

  toggle: 'tooltip',
  alt:    Ember.computed.alias('user.name'),
  title:  Ember.computed.alias('alt'),
  src:    Ember.computed.alias('user.avatarUrl')
});
