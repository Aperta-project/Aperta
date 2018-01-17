import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';
import QAIdent from 'tahi/mixins/components/qa-ident';

let content = Ember.Object.create({ 'ident' : 'my-ident' });

moduleFor('mixin:qa-ident', 'Unit | Mixin | qa-ident', {
  integration: true,

  subject() {
    const component = Ember.Object.extend(QAIdent, {}).create();
    component.set('content', content);
    return component;
  }
});

test('classNameBindings includes QAIdent', function(assert) {
  assert.deepEqual(this.subject().get('classNameBindings'), ['QAIdent']);
});

test('QAIdent returns the right value', function(assert) {
  assert.equal(this.subject().get('QAIdent'), 'qa-ident-my-ident');
});


test('QAIdent squashes disallowed characters', function(assert) {
  content = Ember.Object.create({ 'ident' : 'my ident 1234!@#$%^&' });
  assert.equal(this.subject().get('QAIdent'), 'qa-ident-my_ident____________');
});
