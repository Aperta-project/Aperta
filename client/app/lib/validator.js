import Ember from 'ember';
import presence from 'tahi/lib/validations/presence';
import number   from 'tahi/lib/validations/number';

const { isEmpty } = Ember;

const TYPES = {
  'presence': presence.validation,
  'number': number.validation
};

const DEFAULT_MESSAGES = {
  'presence': presence.defaultMessage,
  'number': number.defaultMessage
};

const generateErrorMessage = function(type, customMessage) {
  if(isEmpty(customMessage)) {
    return DEFAULT_MESSAGES[type];
  }

  if(typeof customMessage === 'function') {
    return customMessage.call(this, type);
  }

  return customMessage;
};

export default {
  validate(key, value, validations) {
    const context = this;

    return _.compact(
      _.map(validations, function(validation) {
        // if validation is defined as key: ['name']
        if(typeof validation === 'string') {
          const pass = TYPES[validation](value);
          if(!pass) {
            return generateErrorMessage(validation);
          }
        }

        // if validation is defined with options:
        // key: [{type: 'name', ...}]
        if(typeof validation === 'object') {
          const options = _.clone(validation);
          const type = options.type;
          delete options.type;

          if(options.skipCheck && options.skipCheck.call(context, key, value)) {
            return false;
          }

          const pass = TYPES[type](value, options);
          if(!pass) {
            return generateErrorMessage.call(context, type, options.message);
          }
        }
      })
    );
  }
};
