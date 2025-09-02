import assert from 'assert';
import { todayMoscowISO, toMoscowSlotISO } from '../lib/time.js';
assert.strictEqual(toMoscowSlotISO('2024-05-01',12),'2024-05-01T12:00:00+03:00');
assert.ok(/^\d{4}-\d{2}-\d{2}$/.test(todayMoscowISO()));
console.log('Frontend time tests passed');
