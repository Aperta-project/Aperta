import DS   from 'ember-data';
import Task from 'tahi/models/task';

export default Task.extend({
  qualifiedType: "PlosBioTechCheck::ChangesForAuthorTask",
  paper: DS.belongsTo('paper')
});
