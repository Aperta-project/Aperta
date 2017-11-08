import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-content', 'card-form-label'],
  tagName: 'label',

  hasLabel: Ember.computed.notEmpty('content.label')
});
