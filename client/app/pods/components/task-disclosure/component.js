import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [
    ':task-disclosure',
    '_taskVisible:task-disclosure--open',
    'typeIdentifier',
  ],

  class: Ember.computed.oneWay('task.componentName'),
  type: Ember.computed.oneWay('task.type'),
  taskOpen: Ember.computed.oneWay('initiallyOpen'),
  notViewable: Ember.computed.not('task.viewable'),

  typeIdentifier: Ember.computed('type', function() {
    const dasherizedType = Ember.String.dasherize(this.get('type'));
    return `task-type-${dasherizedType}`;
  }),

  initiallyOpen: Ember.computed('defaultPreprintTaskOpen', 'title', function() {
    return this.get('defaultPreprintTaskOpen') &&
      this.get('task.title') === 'Preprint Posting' &&
      this.get('task.answers.firstObject.value') === '2';
  }),

  actions: {
    toggleVisibility() {
      if (!this.get('notViewable')) {
        this.toggleProperty('taskOpen');
      }
    }
  }
});
