import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';


moduleForComponent('<%= dasherizedModuleName %>',
                   'Integration | Component | <%= humanizedModuleName %>'); //

var template = hbs`{{<%= dasherizedModuleName %> task=task}}`;

var task = function (){
  return {
    id: 2,
    title: '<%= dasherizedModuleName %>',
    type: '<%= dasherizedModuleName %>',
    completed: false,
    body: '',
    position: 4,
    isMetadataTask: false,
    isSubmissionTask: false,
    phase: null,
    assignedToMe: false,
    attachments: [],
    comments: [],
    participations: [],
    nested_questions: [],
    nested_question_answers: [],
    snapshots: []
  };
};

test('a very important test', function(assert){
  this.set('task', task());

  this.render(template);
  assert(false);
});
