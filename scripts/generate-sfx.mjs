// Génère des SFX WAV (correct, wrong, reward) dans client/public/audio/
// Sans dépendances externes (PCM 16-bit, mono, 44.1kHz)

import fs from 'fs';
import path from 'path';

const outDir = path.resolve(process.cwd(), 'client', 'public', 'audio');
const SR = 44100;

function ensureDir(p) {
  fs.mkdirSync(p, { recursive: true });
}

function envADSR(total, sr, a=0.01, d=0.03, s=0.6, r=0.04) {
  const n = Math.floor(total * sr);
  const arr = new Float32Array(n);
  const na = Math.floor(a * sr), nd = Math.floor(d * sr), nr = Math.floor(r * sr);
  const sustainStart = na + nd;
  const sustainEnd = Math.max(sustainStart, n - nr);
  for (let i=0;i<n;i++){
    if (i < na) arr[i] = i/na; // attack
    else if (i < sustainStart) {
      const t = (i - na)/Math.max(1, nd);
      arr[i] = 1 - (1 - s)*t; // decay
    } else if (i < sustainEnd) arr[i] = s; // sustain
    else {
      const t = (i - sustainEnd)/Math.max(1, nr);
      arr[i] = s * (1 - t); // release
    }
  }
  return arr;
}

function oscSample(type, t, freq) {
  const w = 2*Math.PI*freq*t;
  switch(type){
    case 'square': return Math.sign(Math.sin(w));
    case 'triangle': return 2*Math.asin(Math.sin(w))/Math.PI;
    case 'sawtooth': return 2*(t*freq - Math.floor(0.5 + t*freq));
    default: return Math.sin(w);
  }
}

function renderNotes(notes, type='sine', gain=0.5) {
  const totalDur = notes.reduce((s,n)=>s+n.dur,0);
  const N = Math.floor(totalDur * SR);
  const out = new Float32Array(N);
  let t0 = 0;
  for (const n of notes) {
    const len = Math.floor(n.dur * SR);
    const env = envADSR(n.dur, SR, 0.01, 0.04, 0.7, 0.06);
    for (let i=0;i<len;i++){
      const t = (i)/SR;
      out[t0+i] += gain * env[i] * oscSample(type, t, n.freq);
    }
    t0 += len;
  }
  // soft clip
  for (let i=0;i<N;i++) out[i] = Math.max(-1, Math.min(1, out[i]));
  return out;
}

function floatTo16BitPCM(buffer, offset, input) {
  for (let i = 0; i < input.length; i++, offset += 2) {
    let s = Math.max(-1, Math.min(1, input[i]));
    s = s < 0 ? s * 0x8000 : s * 0x7FFF;
    buffer.writeInt16LE(s, offset);
  }
}

function writeWav(samples, sampleRate = SR) {
  const numChannels = 1;
  const bytesPerSample = 2;
  const blockAlign = numChannels * bytesPerSample;
  const byteRate = sampleRate * blockAlign;
  const dataSize = samples.length * bytesPerSample;
  const buffer = Buffer.alloc(44 + dataSize);
  buffer.write('RIFF', 0);
  buffer.writeUInt32LE(36 + dataSize, 4);
  buffer.write('WAVE', 8);
  buffer.write('fmt ', 12);
  buffer.writeUInt32LE(16, 16); // PCM
  buffer.writeUInt16LE(1, 20);  // format
  buffer.writeUInt16LE(numChannels, 22);
  buffer.writeUInt32LE(sampleRate, 24);
  buffer.writeUInt32LE(byteRate, 28);
  buffer.writeUInt16LE(blockAlign, 32);
  buffer.writeUInt16LE(16, 34); // bits per sample
  buffer.write('data', 36);
  buffer.writeUInt32LE(dataSize, 40);
  floatTo16BitPCM(buffer, 44, samples);
  return buffer;
}

function saveWav(filename, samples) {
  ensureDir(outDir);
  const p = path.join(outDir, filename);
  fs.writeFileSync(p, writeWav(samples));
  console.log('✓ écrit', p, (fs.statSync(p).size/1024).toFixed(1)+'KB');
}

// Définition des 3 SFX
const SFX = {
  correct: () => renderNotes([
    { freq: 523.25, dur: 0.12 }, // C5
    { freq: 659.25, dur: 0.12 }, // E5
    { freq: 783.99, dur: 0.16 }, // G5
  ], 'triangle', 0.6),
  wrong: () => renderNotes([
    { freq: 220.00, dur: 0.18 }, // A3
    { freq: 196.00, dur: 0.22 }, // G3
  ], 'square', 0.5),
  reward: () => renderNotes([
    { freq: 523.25, dur: 0.12 },
    { freq: 659.25, dur: 0.12 },
    { freq: 783.99, dur: 0.14 },
    { freq: 1046.50, dur: 0.18 },
  ], 'sine', 0.6)
};

saveWav('sfx-correct.wav', SFX.correct());
saveWav('sfx-wrong.wav', SFX.wrong());
saveWav('sfx-reward.wav', SFX.reward());

console.log('Terminé.');
