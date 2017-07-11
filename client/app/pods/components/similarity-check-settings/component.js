import Ember from 'ember';

export default Ember.Component.extend({
  restless: Ember.inject.service(),
  store: Ember.inject.service(),

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

  initialSetting: Ember.computed('taskToConfigure', function() {
    let setting = this.get('taskToConfigure.settings').findBy('name', 'ithenticate_automation');
    return setting === undefined ? null : setting.string_value;
  }),

  submissionOption: Ember.computed('initialSetting', function() {
    return this.get('initialSetting') !== 'at_first_full_submission';
  }),

  selectedOption: Ember.computed('initialSetting', function() {
    let setting = this.get('initialSetting');
    if (this.get('selectableOptions').map((x) => x.id).includes(setting)){
      return this.get('selectableOptions').findBy('id', setting);
    }
    else{
      return this.get('selectableOptions')[0];
    }
  }),

  selectEnabled: Ember.computed.reads('submissionOption'),

  fullSubmissionState: Ember.computed('submissionOption', function() {
    return this.get('submissionOption') ? '' : 'checked';
  }),

  afterState: Ember.computed('submissionOption', function() {
    return this.get('submissionOption') ? 'checked' : '';
  }),

  switchState: Ember.computed('initialSetting', function(){
    var setting = this.get('initialSetting');
    var state = {value: true};
    if (['off',null].includes(setting)){
      state.value = false;
    }
    return state;
  }),

  actions: {
    saveAnswer(newVal) {
      if (newVal){
        this.set('fullSubmissionState','checked');
        this.set('afterState','');
        this.set('submissionOption', false);
      }
      this.set('switchState', {value: newVal});
    },
    setAnswer (value) {
      this.set('submissionOption', value);
    },
    selectionSelected(selection) {
      this.set('selectedOption', selection);
    },
    close() {
      this.get('close')();
    },
    saveSettings () {
      var settingValue = null;
      var taskTemplateId = this.get('taskToConfigure.id');
      if (this.get('switchState').value){
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
      }).then((data)=> {
        this.get('store').pushPayload(data);
        this.get('close')();
      });
    }
  }
});
