import Ember from 'ember';

export default Ember.Component.extend({
  restless: Ember.inject.service('restless'),
  classNames: ['similarity-check-settings'],
  selectableOptions: [
    {
      id: 'after_first_major_revise_decision',
      text: 'first major revision'
    },
    {
      id: 'after_first_minor_revise_decision',
      text: 'first minor revision'
    },
    {
      id: 'after_any_first_revise_decision',
      text: 'any first revision'
    }
  ],

  submissionOption: false,

  selectedOption: Ember.computed('submissionOption', function() {
    return this.get('selectableOptions')[0];
  }),

  selectEnabled: Ember.computed('submissionOption', function() {
    return this.get('submissionOption');
  }),

  fullSubmissionState: Ember.computed('submissionOption', function() {
    return this.get('submissionOption') ? '' : 'checked';
  }),

  afterState: Ember.computed('submissionOption', function() {
    return this.get('submissionOption') ? 'checked' : '';
  }),

  switchState: false,

  optionsVisible: Ember.computed('switchState', function() {
    return this.get('switchState') ? 'show`' : 'hide';
  }),

  actions: {
    saveAnswer(newVal) {
      this.set('switchState', newVal);
    },
    clickOption (value) {
      this.set('submissionOption', value);
    },
    selectionSelected(selection) {
      this.set('selectedOption', selection);
    },
    close() {
      this.attrs.close();
    },
    saveSettings () {
      var settingValue = null;
      var taskTemplateId = this.get('taskToConfigure.id');
      if (this.get('switchState')){
        if (this.get('submissionOption')){
          settingValue = this.get('selectedOption').id;
        }
        else{
          settingValue = 'at_first_full_submission';
        }
      }
      else{
        settingValue = 'off';
      }
      this.get('restless').post('/api/task_templates/' + taskTemplateId + '/similarity_check_settings', {
        value: settingValue
      }).then(()=> {
        this.attrs.close();
      });
    }
  }
});
