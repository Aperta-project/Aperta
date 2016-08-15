import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerDiffAssertions from 'tahi/tests/helpers/diff-assertions';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';

moduleForComponent('cover-letter-task-snapshot',
                   'Integration | Component | cover letter task snapshot',
                   {integration: true,
                     beforeEach: function() {
                       registerDiffAssertions();
                       initTruthHelpers();
                     }});

var snapshot = function(attrs){
  let properties = _.extend({
    attachment: attachment(),
    text: text('interesting cover letter'),
    id: 'foo'
  }, attrs);
  return {
    name: 'cover-letter-task',
    children: [
      {name: 'id', value: properties.id},
      {name: 'cover_letter--attachment', value: properties.attachment},
      {name: 'cover_letter--text', value: properties.text}
    ]
  };
};

let text = function(words){
  return {
    answer_type: 'text',
    answer: words
  };
};

let attachment = function(attrs){
  let properties = _.extend({
    id: 'foo',
    title: 'squid',
    file: 'theFile.jpg',
    striking_image: true,
    file_hash: 'a9876a98c987b96h',
    url: '/path/to/theFile.jpg'
  }, attrs);
  return {
    attachments: [
      {children: [
        {name: 'id', value: properties.id},
        {name: 'title', value: properties.title},
        {name: 'file', value: properties.file},
        {name: 'striking_image', value: properties.striking_image},
        {name: 'file_hash', value: properties.file_hash},
        {name: 'url', value: properties.url}
      ]
      }
    ]
  };
};

var template = hbs`{{cover-letter-task-snapshot
                     snapshot1=newSnapshot
                     snapshot2=oldSnapshot}}`;

test('no diff, no added or removed', function(assert){
  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', snapshot());

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test('Diffs the text', function(assert){
  let secondSnaps = snapshot({text: text('different')});

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent('interesting cover letter', 'different');
});

test('Diffs the attachment filename when the file has changed', function(assert) {
  let firstSnaps = snapshot({attachment: attachment({
    file: 'removedFile.jpg',
    file_hash: 'theoriginalfilehash',
    url: '/path/to/removedFile.jpg'
  })});

  let secondSnaps = snapshot({attachment: attachment({
    file: 'addedFile.jpg',
    file_hash: 'anewhashverydifferentmuchchange',
    url: '/path/to/addedFile.jpg'
  })});

  this.set('oldSnapshot', firstSnaps);
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.linkDiffPresent({
    removed: { text: 'removedFile.jpg', url: '/path/to/removedFile.jpg' },
    added: { text: 'addedFile.jpg', url: '/path/to/addedFile.jpg' }
  });
});

test('Diffs the attachment filename when new', function(assert) {
  let firstSnaps = snapshot({attachment: [] });

  let secondSnaps = snapshot({attachment: attachment({
    file: 'addedFile.jpg',
    file_hash: 'anewhashverydifferentmuchchange',
    url: '/path/to/addedFile.jpg'
  })});

  this.set('oldSnapshot', firstSnaps);
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.linkDiffPresent({
    added: { text: 'addedFile.jpg', url: '/path/to/addedFile.jpg' }
  });
});

