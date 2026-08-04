// =====================================================================
//  Paradigmas de Programação - Aula 1
//  Linguagem: Java 17+   Plataforma online: https://onecompiler.com/java
//                        (ou JDoodle, Replit, OnlineGDB)
//  Java cobre orientação a objetos (Aula 11) e threads (Aula 14).
//  A classe precisa se chamar Aula01 e o arquivo, Aula01.java.
// =====================================================================
import java.util.List;
import java.util.ArrayList;
import java.util.stream.IntStream;
import java.util.stream.Collectors;

public class Aula01 {

    static final int N = 200_000;

    static List<Integer> dados() {
        List<Integer> xs = new ArrayList<>(N);
        for (int i = 1; i <= N; i++) xs.add(i);
        return xs;
    }

    // 1. IMPERATIVO: o estilo original da linguagem
    static long imperativo(List<Integer> xs) {
        long total = 0;
        for (int x : xs) {
            if (x % 2 == 0) total += (long) x * x;   // mutação
        }
        return total;
    }

    // 2. FUNCIONAL: streams, disponíveis desde o Java 8 (2014)
    static long funcional(List<Integer> xs) {
        return xs.stream()
                 .filter(x -> x % 2 == 0)
                 .mapToLong(x -> (long) x * x)
                 .sum();
    }

    // 3. ORIENTADO A OBJETOS: o estado encapsulado em um objeto
    static class Somador {
        private long total = 0;
        Somador oferecer(int x) {
            if (x % 2 == 0) total += (long) x * x;
            return this;
        }
        long total() { return total; }
    }

    static long orientadoAObjetos(List<Integer> xs) {
        Somador s = new Somador();
        for (int x : xs) s.oferecer(x);
        return s.total();
    }

    // 4. PARALELO: memória compartilhada gerenciada pela biblioteca.
    //    Só é seguro porque a operação é associativa e sem efeitos (Aula 14).
    static long paralelo(List<Integer> xs) {
        return xs.parallelStream()
                 .filter(x -> x % 2 == 0)
                 .mapToLong(x -> (long) x * x)
                 .sum();
    }

    static String barra(double v, double pico) {
        int n = Math.max(1, (int) Math.round(v / pico * 40));
        return "#".repeat(n);
    }

    public static void main(String[] args) {
        List<Integer> xs = dados();
        long esperado = imperativo(xs);

        System.out.println("=".repeat(62));
        System.out.println("  PARADIGMAS DE PROGRAMACAO - AULA 1 - Java");
        System.out.println("  Problema: somar os quadrados dos pares de 1 a 200.000");
        System.out.println("=".repeat(62));
        System.out.printf("  Resultado esperado: %d%n%n", esperado);

        String[] nomes = {"Imperativo", "Streams", "Orient. a objetos", "Paralelo"};
        double[] tempos = new double[4];

        for (int i = 0; i < 4; i++) {
            long t0 = System.nanoTime();
            long r = switch (i) {
                case 0 -> imperativo(xs);
                case 1 -> funcional(xs);
                case 2 -> orientadoAObjetos(xs);
                default -> paralelo(xs);
            };
            tempos[i] = (System.nanoTime() - t0) / 1_000_000.0;
            if (r != esperado) throw new IllegalStateException("divergiu em " + nomes[i]);
        }

        double pico = 0;
        for (double t : tempos) pico = Math.max(pico, t);

        System.out.println("  TEMPO DE EXECUCAO");
        for (int i = 0; i < 4; i++) {
            System.out.printf("  %-18s %7.2f ms  %s%n", nomes[i], tempos[i], barra(tempos[i], pico));
        }

        System.out.println();
        System.out.println("  Os quatro devolvem o MESMO numero.");
        System.out.println("  Java nasceu imperativa e OO; ganhou lambdas em 2014.");
        System.out.println("  Nenhuma linguagem viva fica num paradigma so (Aula 1).");
        System.out.println();
        System.out.println("  >>> AMBIENTE JAVA OK <<<");
    }
}
