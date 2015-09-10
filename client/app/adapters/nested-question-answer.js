import Ember from 'ember';
import ApplicationAdapter from 'tahi/adapters/application';

export default ApplicationAdapter.extend({
  buildURL: function(modelName, id, snapshot, requestType, query){
    let nestedQuestionId = snapshot.get('nestedQuestion.id');
    Ember.assert(`Expected a nestedQuestion.id but didn't find one`, nestedQuestionId);

    let namespace = this.get('namespace');
    if(namespace){
      namespace = `${namespace}`;
    } else {
      namespace = "";
    }

    let url = `/${namespace}/nested_questions/${nestedQuestionId}/answers`;
    return url;
  }
});
