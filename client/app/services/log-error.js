export default function(error) {
  error = new Error(error);
  if (error.message) { console.log('\n' + error.message + '\n'); }
  if (error.stack)   { console.log('\n' + error.stack   + '\n'); }
}
