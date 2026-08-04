# =====================================================================
#  Paradigmas de Programação - Aula 1
#  Linguagem: Python 3            Plataforma sugerida: Google Colab
#  Rode sem instalar nada. Não usa matplotlib: o gráfico é em ASCII,
#  para funcionar também em Replit, OnlineGDB, Programiz e paiza.io.
# =====================================================================
import time

DADOS = list(range(1, 200_001))
ESPERADO = sum(x * x for x in DADOS if x % 2 == 0)

# --- 1. IMPERATIVO: descreve o percurso, muta um acumulador ----------
def imperativo(nums):
    total = 0
    for x in nums:
        if x % 2 == 0:
            total = total + x * x      # uma mutação por número par
    return total

# --- 2. FUNCIONAL: composição de transformações, zero mutação --------
from functools import reduce
def funcional(nums):
    return reduce(lambda a, b: a + b,
                  map(lambda x: x * x,
                      filter(lambda x: x % 2 == 0, nums)), 0)

# --- 3. ORIENTADO A OBJETOS: o estado apenas mudou de lugar ----------
class Somador:
    def __init__(self):
        self._total = 0
    def oferecer(self, x):
        if x % 2 == 0:
            self._total += x * x
        return self
    @property
    def total(self):
        return self._total

def orientado_a_objetos(nums):
    s = Somador()
    for x in nums:
        s.oferecer(x)
    return s.total

# --- 4. DECLARATIVO: diz o QUE, não o COMO --------------------------
def declarativo(nums):
    return sum(x * x for x in nums if x % 2 == 0)

# --- Medição e gráfico em ASCII -------------------------------------
def cronometrar(f, nums, repeticoes=3):
    melhor = float("inf")
    for _ in range(repeticoes):
        t = time.perf_counter()
        r = f(nums)
        melhor = min(melhor, time.perf_counter() - t)
    assert r == ESPERADO, "resultado divergente!"
    return melhor * 1000

def barra(valor, maximo, largura=40):
    return "#" * max(1, round(valor / maximo * largura))

ESTILOS = [("Imperativo", imperativo, 100_000),
           ("Funcional", funcional, 0),
           ("Orient. a objetos", orientado_a_objetos, 100_000),
           ("Declarativo", declarativo, 0)]

print("=" * 62)
print("  PARADIGMAS DE PROGRAMACAO - AULA 1 - Python")
print("  Problema: somar os quadrados dos numeros pares de 1 a 200.000")
print("=" * 62)
print("  Resultado esperado:", ESPERADO, "\n")

medidas = [(nome, cronometrar(f, DADOS), mut) for nome, f, mut in ESTILOS]
pico = max(t for _, t, _ in medidas)

print("  TEMPO DE EXECUCAO")
for nome, t, _ in medidas:
    print(f"  {nome:<18} {t:7.1f} ms  {barra(t, pico)}")

print("\n  MUTACOES DE ESTADO (a metrica conceitualmente decisiva)")
for nome, _, mut in medidas:
    print(f"  {nome:<18} {mut:7d}     {'#' * 40 if mut else '(nenhuma)'}")

print("\n  Os quatro devolvem o MESMO numero por caminhos diferentes.")
print("  Zero mutacao = paralelizavel e testavel sem esforco (Aulas 4 e 14).")
print("\n  >>> AMBIENTE PYTHON OK <<<")
