// =====================================================================
//  Paradigmas de Programação - Aula 1
//  Linguagem: JavaScript   Plataforma online: https://playcode.io
//                          ou o console do próprio navegador (F12),
//                          ou Node.js em Replit / OnlineGDB.
//  JavaScript cobre protótipos e delegação na Aula 11.
// =====================================================================

const N = 200000;
const DADOS = Array.from({ length: N }, (_, i) => i + 1);
const ESPERADO = DADOS.reduce((a, x) => (x % 2 === 0 ? a + x * x : a), 0);

// 1. IMPERATIVO
function imperativo(xs) {
  let total = 0;
  for (let i = 0; i < xs.length; i++) {
    if (xs[i] % 2 === 0) total += xs[i] * xs[i]; // mutação
  }
  return total;
}

// 2. FUNCIONAL: filter + map + reduce
const funcional = (xs) =>
  xs.filter((x) => x % 2 === 0).map((x) => x * x).reduce((a, b) => a + b, 0);

// 3. OBJETO POR CLASSE (açúcar sintático sobre protótipos)
class Somador {
  constructor() { this.total = 0; }
  oferecer(x) { if (x % 2 === 0) this.total += x * x; return this; }
}
function porClasse(xs) {
  const s = new Somador();
  xs.forEach((x) => s.oferecer(x));
  return s.total;
}

// 4. PROTÓTIPOS E DELEGAÇÃO: o modelo REAL do JavaScript (Aula 11).
//    Não há classes de verdade: há objetos que delegam a outros objetos.
const somadorProto = {
  init() { this.total = 0; return this; },
  oferecer(x) { if (x % 2 === 0) this.total += x * x; return this; },
};
function porPrototipo(xs) {
  const s = Object.create(somadorProto).init(); // delegação, não instanciação
  for (const x of xs) s.oferecer(x);
  return s.total;
}

// --- Medição e gráfico em ASCII --------------------------------------
const agora = () =>
  typeof performance !== "undefined" ? performance.now() : Date.now();

function cronometrar(f) {
  const t0 = agora();
  const r = f(DADOS);
  const dt = agora() - t0;
  if (r !== ESPERADO) throw new Error("resultado divergente!");
  return dt;
}

const barra = (v, pico) => "#".repeat(Math.max(1, Math.round((v / pico) * 40)));

const versoes = [
  ["Imperativo", imperativo],
  ["Funcional", funcional],
  ["Classe (ES6)", porClasse],
  ["Prototipo", porPrototipo],
];

console.log("=".repeat(62));
console.log("  PARADIGMAS DE PROGRAMACAO - AULA 1 - JavaScript");
console.log("  Problema: somar os quadrados dos pares de 1 a 200.000");
console.log("=".repeat(62));
console.log("  Resultado esperado:", ESPERADO, "\n");

const medidas = versoes.map(([nome, f]) => [nome, cronometrar(f)]);
const pico = Math.max(...medidas.map(([, t]) => t));

console.log("  TEMPO DE EXECUCAO");
for (const [nome, t] of medidas) {
  console.log(
    "  " + nome.padEnd(16) + t.toFixed(2).padStart(8) + " ms  " + barra(t, pico)
  );
}

console.log("\n  Classe e Prototipo produzem o mesmo objeto:");
console.log("  Object.getPrototypeOf funciona nos dois casos.");
console.log("  class em JavaScript e acucar sintatico (Aula 11).");
console.log("\n  >>> AMBIENTE JAVASCRIPT OK <<<");
