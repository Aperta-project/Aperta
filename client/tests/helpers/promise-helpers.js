// For many tests, it's useful to have a promise that resolves
// immediately and synchronously. instaPromise creates one of them.
// This implementation doesn't currently allow a chained promise to
// reject if its parent resolves, so it's not a perfect mock, but it
// can be refined if need-be.

export function instaPromise(resolves, value) {
  if (resolves) {
    return {
      then(callback) {
        const newVal = callback(value);
        return instaPromise(resolves, newVal);
      },
      catch() { return instaPromise(resolves, value); }
    };
  } else {
    return {
      then() { return instaPromise(resolves, value); },
      catch(callback) {
        const newVal = callback(value);
        return instaPromise(resolves, newVal);
      }
    };
  }
}
