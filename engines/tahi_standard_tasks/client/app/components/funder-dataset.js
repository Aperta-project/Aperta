import Ember from 'ember';
import { task as concurrencyTask } from 'ember-concurrency';

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
    let answer = model.answerForIdent('funder--had_influence--role_description');
    answer.set('value', value);
    answer.save();
  },

  loadCard: concurrencyTask( function * () {
    let model = this.get('model');
    yield Ember.RSVP.all([
      model.get('card'),
      model.get('answers')
    ]);
  }),
  actions: {
    userSelectedYesForFunderInfluence(){
      this.setFunderRoleDescriptionAnswer('');
    },

    userSelectedNoForFunderInfluence(){
      this.setFunderRoleDescriptionAnswer('');
    },

    removeFunder(disabled) {
      if (this.get('disabled')) {
        return;
      }
      return this.get('model').destroyRecord();
    }
  }
});
