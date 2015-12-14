import Ember from "ember";
import Utils from "tahi/services/utils";

export default  Ember.Component.extend({
  classNames: ["dataset"],

  uniqueName: (function() {
    return "funder-had-influence-" + (Utils.generateUUID());
  }).property(),

  _saveModel: function() {
    return this.get("model").save();
  },

  change: function(e) {
    return Ember.run.debounce(this, this._saveModel, 400);
  },

  setFunderRoleDescriptionAnswer: function(value){
    let model = this.get('model');
    let answer = model.answerForQuestion('funder--had_influence--role_description');
    answer.set('value', value);
    answer.save();
  },

  actions: {
    userSelectedYesForFunderInfluence: function(){
      this.setFunderRoleDescriptionAnswer('');
    },

    userSelectedNoForFunderInfluence: function(){
      this.setFunderRoleDescriptionAnswer('');
    },

    removeFunder: function(disabled) {
      if (this.get('disabled')) {
        return;
      }
      return this.get("model").destroyRecord();
    }
  }
});
