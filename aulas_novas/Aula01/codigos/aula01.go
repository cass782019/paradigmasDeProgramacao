// =====================================================================
//
//	Paradigmas de Programação - Aula 1
//	Linguagem: Go        Plataforma online: https://go.dev/play
//	                     (cole o arquivo inteiro e clique em Run)
//	Go cobre CSP e canais na Aula 15.
//
// =====================================================================
package main

import (
	"fmt"
	"strings"
	"sync"
	"time"
)

const N = 200000

func dados() []int {
	xs := make([]int, N)
	for i := range xs {
		xs[i] = i + 1
	}
	return xs
}

// 1. IMPERATIVO: o estilo idiomático em Go. Sem map/filter na linguagem.
func imperativo(xs []int) int {
	total := 0
	for _, x := range xs {
		if x%2 == 0 {
			total += x * x // mutação explícita
		}
	}
	return total
}

// 2. ORDEM SUPERIOR: Go tem funções de primeira classe, ainda que verbosas
func filtrar(xs []int, p func(int) bool) []int {
	saida := make([]int, 0, len(xs))
	for _, x := range xs {
		if p(x) {
			saida = append(saida, x)
		}
	}
	return saida
}

func mapear(xs []int, f func(int) int) []int {
	saida := make([]int, len(xs))
	for i, x := range xs {
		saida[i] = f(x)
	}
	return saida
}

func reduzir(xs []int, inicial int, f func(int, int) int) int {
	acc := inicial
	for _, x := range xs {
		acc = f(acc, x)
	}
	return acc
}

func ordemSuperior(xs []int) int {
	pares := filtrar(xs, func(x int) bool { return x%2 == 0 })
	quadrados := mapear(pares, func(x int) int { return x * x })
	return reduzir(quadrados, 0, func(a, b int) int { return a + b })
}

//  3. CSP: goroutines e canais. O estado NÃO é compartilhado — ele viaja
//     pelo canal. Prévia da Aula 15.
func porCanais(xs []int, trabalhadores int) int {
	tamanho := len(xs) / trabalhadores
	parciais := make(chan int, trabalhadores)
	var wg sync.WaitGroup

	for w := 0; w < trabalhadores; w++ {
		inicio := w * tamanho
		fim := inicio + tamanho
		if w == trabalhadores-1 {
			fim = len(xs)
		}
		wg.Add(1)
		go func(fatia []int) { // goroutine: processo leve
			defer wg.Done()
			soma := 0
			for _, x := range fatia {
				if x%2 == 0 {
					soma += x * x
				}
			}
			parciais <- soma // comunicação por canal, não por memória
		}(xs[inicio:fim])
	}
	wg.Wait()
	close(parciais)

	total := 0
	for p := range parciais {
		total += p
	}
	return total
}

// 4. MEMÓRIA COMPARTILHADA COM LOCK: o outro modelo, o da Aula 14
func porMutex(xs []int, trabalhadores int) int {
	total := 0
	var mu sync.Mutex
	var wg sync.WaitGroup
	tamanho := len(xs) / trabalhadores

	for w := 0; w < trabalhadores; w++ {
		inicio := w * tamanho
		fim := inicio + tamanho
		if w == trabalhadores-1 {
			fim = len(xs)
		}
		wg.Add(1)
		go func(fatia []int) {
			defer wg.Done()
			soma := 0
			for _, x := range fatia {
				if x%2 == 0 {
					soma += x * x
				}
			}
			mu.Lock() // sem este lock, o resultado seria não determinístico
			total += soma
			mu.Unlock()
		}(xs[inicio:fim])
	}
	wg.Wait()
	return total
}

func barra(v, pico float64) string {
	n := int(v / pico * 40)
	if n < 1 {
		n = 1
	}
	return strings.Repeat("#", n)
}

func main() {
	xs := dados()
	esperado := imperativo(xs)

	fmt.Println(strings.Repeat("=", 62))
	fmt.Println("  PARADIGMAS DE PROGRAMACAO - AULA 1 - Go")
	fmt.Println("  Problema: somar os quadrados dos pares de 1 a 200.000")
	fmt.Println(strings.Repeat("=", 62))
	fmt.Printf("  Resultado esperado: %d\n\n", esperado)

	type medida struct {
		nome string
		ms   float64
	}
	versoes := []struct {
		nome string
		f    func() int
	}{
		{"Imperativo", func() int { return imperativo(xs) }},
		{"Ordem superior", func() int { return ordemSuperior(xs) }},
		{"CSP (4 canais)", func() int { return porCanais(xs, 4) }},
		{"Mutex (4 threads)", func() int { return porMutex(xs, 4) }},
	}

	medidas := []medida{}
	pico := 0.0
	for _, v := range versoes {
		t0 := time.Now()
		r := v.f()
		ms := float64(time.Since(t0).Microseconds()) / 1000
		if r != esperado {
			panic("resultado divergente em " + v.nome)
		}
		if ms > pico {
			pico = ms
		}
		medidas = append(medidas, medida{v.nome, ms})
	}

	// O sandbox do Go Playground usa um relogio FALSO, que so avanca quando
	// todas as goroutines bloqueiam. Por isso os tempos podem sair zerados la:
	// isso nao e um erro do programa, e uma propriedade do ambiente.
	if pico <= 0 {
		fmt.Println("  TEMPO DE EXECUCAO: nao mensuravel neste ambiente")
		fmt.Println("  (o Go Playground congela o relogio durante a computacao;")
		fmt.Println("   rode localmente com 'go run aula01.go' para ver os tempos)")
	} else {
		fmt.Println("  TEMPO DE EXECUCAO")
		for _, m := range medidas {
			fmt.Printf("  %-18s %7.2f ms  %s\n", m.nome, m.ms, barra(m.ms, pico))
		}
	}

	fmt.Println("\n  Os quatro devolvem o MESMO numero.")
	fmt.Println("  CSP e Mutex resolvem o mesmo problema de concorrencia por")
	fmt.Println("  caminhos opostos: mensagem versus memoria compartilhada.")
	fmt.Println("\n  >>> AMBIENTE GO OK <<<")
}
