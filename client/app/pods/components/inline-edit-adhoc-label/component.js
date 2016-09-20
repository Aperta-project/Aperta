import Ember from 'ember';

export default Ember.Component.extend({
  editing: false,
  isNew: false,
  bodyPart: null,
  bodyPartType: Ember.computed.alias('bodyPart.type')
});
