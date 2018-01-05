import { module, test } from 'qunit';
import Ember from 'ember';
import QAIdent from 'tahi/mixins/components/qa-ident';

module('mixins | components | QA Ident', {
  beforeEach() {
    const ExtendedObject = Ember.Object.extend(QAIdent, {});
    this.cntrl = ExtendedObject.create({
      content: {ident: 'identifier'}
    });
  }
});

test('with data key delays progress bar', function(assert) {
  const expected = 'qa--' + this.cntrl.content.ident;
  assert.equal(this.cntrl.get('QAIdent'), expected);
});
