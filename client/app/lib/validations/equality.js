export const defaultMessage = 'This field is invalid';

export const validation = function(value, options) {
  const expectedValue = options.value;
  return value === expectedValue;
};
