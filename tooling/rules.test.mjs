import { readFileSync } from 'node:fs';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, setDoc, getDoc, deleteDoc, Timestamp } from 'firebase/firestore';

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
  const favorite = {kind: 'news', itemId: 'n1', createdAt: Timestamp.now()};
  await assertSucceeds(setDoc(doc(alice, 'users/alice'), {name: 'Alice', group: 'CS-221', updatedAt: Timestamp.now()}));
  await assertFails(setDoc(doc(alice, 'users/alice'), {group: 42, updatedAt: Timestamp.now()}));
  await assertFails(setDoc(doc(alice, 'users/alice'), {group: 'CS-221', updatedAt: 'invalid'}));
  await assertFails(setDoc(doc(guest, 'users/alice'), {name: 'Guest'}));
  await assertSucceeds(setDoc(doc(alice, 'users/alice/favorites/news_n1'), favorite));
  await assertSucceeds(getDoc(doc(alice, 'users/alice/favorites/news_n1')));
  await assertFails(getDoc(doc(bob, 'users/alice/favorites/news_n1')));
  await assertFails(getDoc(doc(guest, 'users/alice/favorites/news_n1')));
  await assertFails(setDoc(doc(bob, 'users/alice/favorites/news_n1'), favorite));
  await assertFails(setDoc(doc(guest, 'users/alice/favorites/news_n1'), favorite));
  for (const invalid of [{...favorite, kind: 'lesson'}, {...favorite, itemId: ''}, {...favorite, createdAt: 'today'}, {...favorite, role: 'admin'}, {kind: 'news'}]) {
    await assertFails(setDoc(doc(alice, 'users/alice/favorites/invalid'), invalid));
  }
  await assertFails(deleteDoc(doc(bob, 'users/alice/favorites/news_n1')));
  await assertSucceeds(deleteDoc(doc(alice, 'users/alice/favorites/news_n1')));
  console.log('PASS: Firestore ownership, group and favorite schema checks');
} finally {
  await environment.cleanup();
}
