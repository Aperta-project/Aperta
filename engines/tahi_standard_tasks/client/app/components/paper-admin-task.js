import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import Select2Assignees from 'tahi/mixins/controllers/select-2-assignees';
import { eligibleUsersPath } from 'tahi/lib/api-path-helpers';

export default TaskComponent.extend(Select2Assignees, {
  select2RemoteUrl: Ember.computed('task.id', function() {
    return eligibleUsersPath(this.get('task.id'), 'admins');
  }),

  actions: {
    assignAdmin(select2User) {
      let user = this.get('store').findOrPush('user', select2User);
      this.set('task.admin', user);
      this.send('save');
    }
  }
});
