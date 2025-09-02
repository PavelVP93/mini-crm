export function todayMoscowISO(){
  const now = new Date();
  const moscowNow = new Date(now.toLocaleString('en-US',{timeZone:'Europe/Moscow'}));
  return moscowNow.toISOString().slice(0,10);
}
export function toMoscowSlotISO(date,hour){
  return `${date}T${String(hour).padStart(2,'0')}:00:00+03:00`;
}
