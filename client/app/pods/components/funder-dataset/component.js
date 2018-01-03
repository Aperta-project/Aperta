import Ember from 'ember';

export default  Ember.Component.extend({
  classNames: ['dataset'],
  enabled: Ember.computed.not('disabled'),

  _saveModel() {
    return this.get('model').save();
  },

  change() {
    return Ember.run.debounce(this, this._saveModel, 400);
  },

  setFunderRoleDescriptionAnswer: function(value){
    let model = this.get('model');
    let answer = model.answerForQuestion('funder--had_influence--role_description');
    answer.set('value', value);
    answer.save();
  },

  actions: {
    saveRoleDescription(contents) {
      this.setFunderRoleDescriptionAnswer(contents);
      this.change();
    },

    saveComments(contents) {
      this.get('model').set('additionalComments', contents);
      this.change();
    },

    userSelectedYesForFunderInfluence(){
      this.setFunderRoleDescriptionAnswer('');
    },

    userSelectedNoForFunderInfluence(){
      this.setFunderRoleDescriptionAnswer('');
    },

    removeFunder() {
      if (this.get('enabled')) {
        return this.get('model').destroyRecord();
      }
    }
  }
});
