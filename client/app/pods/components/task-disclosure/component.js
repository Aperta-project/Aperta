import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [
    ':task-disclosure',
    '_taskVisible:task-disclosure--open',
    'typeIdentifier',
  ],

  class: Ember.computed.oneWay('task.componentName'),
  type: Ember.computed.oneWay('task.type'),
  taskOpen: false,
  notViewable: Ember.computed.not('task.viewable'),

  typeIdentifier: Ember.computed('type', function() {
    const dasherizedType = Ember.String.dasherize(this.get('type'));
    return `task-type-${dasherizedType}`;
  }),

  actions: {
    toggleVisibility() {
      if (!this.get('notViewable')) {
        this.toggleProperty('taskOpen');
      }
    }
  }
});
