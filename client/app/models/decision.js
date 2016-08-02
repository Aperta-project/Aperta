import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  authorResponse: DS.attr('string'),
  // Draft is always != competed, so we only serialize one.
  completed: Ember.computed.not('draft'),
  createdAt: DS.attr('date'),
  draft: DS.attr('boolean'),
  initial: DS.attr('boolean'),
  invitations: DS.hasMany('invitation', { async: false }),
  latest: DS.attr('boolean'),
  latestRegistered: DS.attr('boolean'),
  letter: DS.attr('string'),
  majorVersion: DS.attr('number'),
  minorVersion: DS.attr('number'),
  nestedQuestionAnswers: DS.hasMany('nested-question-answer', { async: false }),
  paper: DS.belongsTo('paper', { async: false }),
  registeredAt: DS.attr('date'),
  rescindable: DS.attr('boolean'),
  rescinded: DS.attr('boolean'),
  verdict: DS.attr('string'),

  terminal: Ember.computed.match('verdict', /^(accept|reject)$/),

  restless: Ember.inject.service('restless'),
  rescind() {
    return this.get('restless')
      .put(`/api/decisions/${this.get('id')}/rescind`)
      .then((data) => {
        this.get('store').pushPayload(data);
        return this;
      });
  },

  register(task) {
    const registerPath = `/api/decisions/${this.get('id')}/register`;
    return this.save().then(() => {
      return this.get('restless')
        .put(registerPath, {task_id: task.get('id')})
        .then((data) => {
        this.get('store').pushPayload(data);
        return this;
      });
    });
  },

  revisionNumber: Ember.computed('minorVersion', 'majorVersion', function() {
    return `${this.get('majorVersion')}.${this.get('minorVersion')}`;
  })
});
