import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import Select2Assignees from 'tahi/mixins/controllers/select-2-assignees';

export default TaskComponent.extend(Select2Assignees, {
  select2RemoteUrl: Ember.computed('task.paper', function() {
    return '/api/filtered_users/admins/' + this.get('task.paper.id') + '/';
  }),

  actions: {
    assignAdmin(select2User) {
      this.store.find('user', select2User.id).then(user => {
        this.set('task.admin', user);
        this.send('save');
      });
    }
  }
});
