import Ember from "ember";
import Utils from "tahi/services/utils";

export default  Ember.Component.extend({
  classNames: ["dataset"],

  funderHadInfluenceQuestion: Ember.computed("model", "model.nestedQuestions.@each", function(){
    return this.get("model").findQuestion("funder_had_influence");
  }),

  funderRoleDescriptionQuestion: Ember.computed("model", "model.nestedQuestions.@each", function(){
    return this.get("model").findQuestion("funder_role_description");
  }),

  uniqueName: (function() {
    return "funder-had-influence-" + (Utils.generateUUID());
  }).property(),

  _saveModel: function() {
    return this.get("model").save();
  },

  change: function(e) {
    return Ember.run.debounce(this, this._saveModel, 400);
  },

  actions: {
    userSelectedYesForFunderInfluence: function(){
      // let answer = this.get('funderHadInfluenceQuestion.answer');
      // answer.set('value', '');
      // answer.save();
    },

    userSelectedNoForFunderInfluence: function(){
      let answer = this.get('funderHadInfluenceQuestion.answer');
      answer.destroyRecord();
      // this.get("model.getNestedQuestion")
    },

    removeFunder: function(disabled) {
      if (this.get('disabled')) {
        return;
      }
      return this.get("model").destroyRecord();
    }
  }
});
