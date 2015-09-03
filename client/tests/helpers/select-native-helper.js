import Ember from 'ember';

export default function() {
  Ember.Test.registerAsyncHelper('pickFromSelect', function(app, selector, ...texts) {
    let options = app.testHelpers.findWithAssert(`${selector} option`);

    options.each(function() {
      let option = Ember.$(this);

      Ember.run(() => {
        this.selected = texts.some(text => option.is(`:contains('${text}')`));
        option.trigger('change');
      });
    });

    return app.testHelpers.wait();
  });
}
