import Ember from 'ember';
import ApplicationAdapter from 'tahi/adapters/application';

export default ApplicationAdapter.extend({
  buildURL: function(modelName, id, snapshot){
    let nestedQuestionId = snapshot.get('nestedQuestion.id');
    Ember.assert(`Expected a nestedQuestion.id but didn't find one`, nestedQuestionId);

    let namespace = this.get('namespace');
    if(namespace){
      namespace = `${namespace}`;
    } else {
      namespace = "";
    }

    let url = '';
    if (id) {
     url = `/${namespace}/nested_questions/${nestedQuestionId}/answers/${id}`;
    } else {
      url = `/${namespace}/nested_questions/${nestedQuestionId}/answers`;
    }
    return url;
  }
});
