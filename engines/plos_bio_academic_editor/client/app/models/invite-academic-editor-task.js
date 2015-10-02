import Ember from 'ember';
import DS from 'ember-data';
import Task from 'tahi/models/task';

const { computed } = Ember;

export default Task.extend({
  academic_editor: DS.belongsTo('user'),
  invitation: DS.belongsTo('invitation'),
  letter: DS.attr('string'),

  invitationTemplate: computed('letter', function() {
    return JSON.parse(this.get('letter'));
  })
});
