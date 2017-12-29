import Task from 'tahi/pods/task/model';

/**
 * The card-preview model only exists as an owner for ephemeral
 * answers that are used in the card-content preview.
 */
export default Task.extend({
  save(){
    // card previews should never save themselves
  }
});
