import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'header',
  classNames: ['overlay-header'],

  task: null,
  animateOut: null,

  paper: Ember.computed.alias('task.paper')
});
