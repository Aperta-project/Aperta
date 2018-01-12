import DS   from 'ember-data';
import Task from 'tahi/pods/task/model';

export default Task.extend({
  qualifiedType: "PlosBioTechCheck::ChangesForAuthorTask",
  paper: DS.belongsTo('paper'),
  isOnlyEditableIfPaperEditable: true
});
