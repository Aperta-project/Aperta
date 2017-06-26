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

  initialSetting: Ember.computed('initialSetting', function() {
    var setting = this.get('taskToConfigure.settings')
      .filter((x) => {
        return x.name === 'ithenticate_automation';
      });
    return setting.length > 0 ? setting[0].value : null;
  }),

  submissionOption: Ember.computed('submissionOption', function() {
    return this.get('initialSetting') !== 'at_first_full_submission';
  }),

  selectedOption: Ember.computed('submissionOption', function() {
    var setting = this.get('initialSetting');
    if (this.get('selectableOptions').map((x) => x.id).includes(setting)){
      return this.get('selectableOptions')
        .filter((x) => {
          return x.id === setting;
        })[0];
    }
    else{
      return this.get('selectableOptions')[0];
    }
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

  switchState: Ember.computed('switchState', function(){
    var setting = this.get('initialSetting');
    var state = Ember.Object.create({value: true});
    if (['off',null].includes(setting)){
      state.set('value', false);
    }
    return state;
  }),

  content: Ember.Object.create({
    text: 'Automatic Checks'
  }),

  optionsVisible: Ember.computed('switchState', function() {
    return this.get('switchState').value ? 'show' : 'hide';
  }),

  actions: {
    saveAnswer(newVal) {
      if (newVal){
        this.set('fullSubmissionState','checked');
        this.set('afterState','');
        this.set('submissionOption', false);
      }
      this.set('switchState', Ember.Object.create({value: newVal}));
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
        this.attrs.close();
      });
    }
  }
});
