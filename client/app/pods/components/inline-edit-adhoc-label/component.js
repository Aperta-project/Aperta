import Ember from 'ember';

export default Ember.Component.extend({
  editing: false,
  bodyPart: null,
  bodyPartType: Ember.computed.alias('bodyPart.type')
});
