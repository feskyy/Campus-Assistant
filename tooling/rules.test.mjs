import { readFileSync } from 'node:fs';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, setDoc, getDoc } from 'firebase/firestore';

const environment = await initializeTestEnvironment({
  projectId: 'demo-campus-assistant',
  firestore: { host: '127.0.0.1', port: 8080, rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
});
try {
  const alice = environment.authenticatedContext('alice').firestore();
  const bob = environment.authenticatedContext('bob').firestore();
  const guest = environment.unauthenticatedContext().firestore();
  await assertSucceeds(setDoc(doc(alice, 'users/alice'), { name: 'Alice' }));
  await assertSucceeds(getDoc(doc(alice, 'users/alice')));
  await assertFails(getDoc(doc(bob, 'users/alice')));
  await assertFails(setDoc(doc(bob, 'users/alice'), { name: 'Bob' }));
  await assertFails(getDoc(doc(guest, 'users/alice')));
  await assertFails(setDoc(doc(alice, 'users/alice'), { name: 'Alice', role: 'admin' }));
  await assertFails(setDoc(doc(alice, 'users/alice'), { name: '' }));
  await assertSucceeds(setDoc(doc(alice, 'users/alice/devices/test'), { token: 'test-token' }));
  await assertFails(getDoc(doc(bob, 'users/alice/devices/test')));
  await assertFails(setDoc(doc(alice, 'arbitrary/data'), { name: 'denied' }));
  console.log('PASS: 10 Firestore ownership and schema checks');
} finally {
  await environment.cleanup();
}
