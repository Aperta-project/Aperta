export default function(msg) {
  let e = new Error(msg);
  if (e.message) { console.log(e.message); }
  console.log(e.stack || e.message);
}
