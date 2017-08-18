import Ember from 'ember';

export default Ember.Component.extend({

  classNames: ['similarity-check-settings'],
  selectableOptions: [
    {
      id: 'after_major_revise_decision',
      text: 'major revision'
    },
    {
      id: 'after_minor_revise_decision',
      text: 'minor revision'
    },
    {
      id: 'after_any_first_revise_decision',
      text: 'any first revision'
    }
  ],

  initialSetting: Ember.computed('taskToConfigure', function() {
    let setting = this.get('taskToConfigure.settings').findBy('name', 'ithenticate_automation');
    return setting.get('value');
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

  settingValue: Ember.computed('switchState', 'submissionOption', function(){
    if (this.get('switchState').value) {
      if (this.get('submissionOption')) {
        return this.get('selectedOption').id;
      } else {
        return 'at_first_full_submission';
      }
    } else {
      return 'off';
    }
  }),

  actions: {
    changeAnswer(newVal) {
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
      this.get('taskToConfigure').updateSetting('ithenticate_automation', this.get('settingValue')).then(()=> {
        this.get('close')();
      });
    }
  }
});
