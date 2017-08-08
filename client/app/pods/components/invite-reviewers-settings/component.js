import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  settingName: 'review_duration_period',
  setting: Ember.computed('taskToConfigure', function(){
    return this.get('taskToConfigure.settings').findBy('name', this.get('settingName'));
  }),
  settingValue: Ember.computed('setting', function(){
    return this.get('setting.value');
  }),
  classNames: ['invite-reviewer-settings'],

  actions: {
    close() {
      this.get('close')();
    },
    saveSettings () {
      let value = parseInt(this.$('input').val());
      if (value) {
        this.get('taskToConfigure').updateSetting(this.get('settingName'), value).then(() => {
          this.get('close')();
        });
      }
    },
  }
});
