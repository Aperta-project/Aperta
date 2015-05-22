import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'img',
  attributeBindings: ['alt', 'src', 'toggle', 'title'],
  classNames: ['user-thumbnail'],

  /**
   * @property user
   * @type {User} Ember.Data model instance
   * @default null
   * @required
   */
  user: null,
  //<validation>
  _validate_user: function() {
    Ember.assert('The `user` property must be set on the user-thumbnail component', !Ember.isEmpty(this.get('user')));
  }.on('init'),
  //</validation>

  toggle: 'tooltip',
  alt:    Ember.computed.alias('user.name'),
  title:  Ember.computed.alias('alt'),
  src:    Ember.computed.alias('user.avatarUrl')
});
