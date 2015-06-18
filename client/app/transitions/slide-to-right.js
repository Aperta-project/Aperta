import slideOver from 'tahi/transitions/tahi-slide-over';
export default function(opts) {
  return slideOver.call(this, 'x', 1, opts);
}
