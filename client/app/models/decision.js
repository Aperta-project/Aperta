import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  invitations: DS.hasMany('invitation', { async: false }),
  paper: DS.belongsTo('paper', { async: false }),
  nestedQuestionAnswers: DS.hasMany('nested-question-answer', { async: false }),
  createdAt: DS.attr('date'),
  isLatest: DS.attr('boolean'),
  isLatestRegistered: DS.attr('boolean'),
  letter: DS.attr('string'),
  revisionNumber: DS.attr('number'),
  verdict: DS.attr('string'),
  authorResponse: DS.attr('string'),
  registered: DS.attr('boolean'),
  initial: DS.attr('boolean'),
  rescinded: DS.attr('boolean'),
  rescindMinorVersion: DS.attr('number'),
  rescindable: DS.attr('boolean'),

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
});
