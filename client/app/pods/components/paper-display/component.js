import Ember from 'ember';

const { alias, not } = Ember.computed;

export default Ember.Component.extend({
  paper: null, // required

  classNames: ['paper-display'],

  body: alias('paper.body'),
  ready: not('paper.processing')
});
