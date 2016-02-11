export const defaultMessage = 'invalid email address';

export const validation = function(value, options) {
  const reg = /\S+@\S+\.\S+/;
  return reg.test(value);
};
