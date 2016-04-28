import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';


moduleForComponent('related-articles-task',
                   'Integration | Component | related_articles_task'); //

var template = hbs`{{related-articles-task task=task}}`;

var task = function (){
  return {
    id: 2,
    title: 'related-articles-task',
    type: 'related-articles-task',
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
    nestedQuestions: [],
    nestedQuestionAnswers: [],
    snapshots: []
  };
};

test('a very important test', function(assert){
  this.set('task', task());

  this.render(template);
  assert(false);
});
