# =====================================================================
#  Paradigmas de Programação - Aula 1
#  Linguagem: Elixir     Plataforma online: https://livebook.dev
#                        (ou Replit, OnlineGDB, glot.io)
#  Elixir cobre o funcional (Aula 5) e os atores (Aula 15).
#  Rode com:  elixir aula01.exs
# =====================================================================

defmodule Aula1 do
  @dados 1..200_000
  def esperado, do: Enum.sum(for x <- @dados, rem(x, 2) == 0, do: x * x)

  # 1. PIPELINE: o operador |> encadeia transformações
  def pipeline do
    @dados
    |> Enum.filter(&(rem(&1, 2) == 0))
    |> Enum.map(&(&1 * &1))
    |> Enum.sum()
  end

  # 2. COMPREENSÃO
  def compreensao, do: Enum.sum(for x <- @dados, rem(x, 2) == 0, do: x * x)

  # 3. RECURSÃO COM PATTERN MATCHING: sem laço, sem atribuição
  def recursivo(lista), do: recursivo(lista, 0)
  defp recursivo([], acc), do: acc
  defp recursivo([x | resto], acc) when rem(x, 2) == 0, do: recursivo(resto, acc + x * x)
  defp recursivo([_ | resto], acc), do: recursivo(resto, acc)

  # 4. ATORES: prévia da Aula 15 — o trabalho é dividido entre processos
  #    isolados que trocam mensagens. Nenhuma memória é compartilhada.
  def por_atores(n_processos \\ 4) do
    pai = self()
    pedacos = @dados |> Enum.to_list() |> Enum.chunk_every(div(200_000, n_processos))

    pedacos
    |> Enum.map(fn pedaco ->
      spawn(fn ->
        parcial = pedaco |> Enum.filter(&(rem(&1, 2) == 0)) |> Enum.map(&(&1 * &1)) |> Enum.sum()
        send(pai, {:parcial, parcial})     # única forma de comunicação
      end)
    end)
    |> Enum.map(fn _ -> receive do {:parcial, v} -> v end end)
    |> Enum.sum()
  end

  def cronometrar(fun) do
    {micros, resultado} = :timer.tc(fun)
    {micros / 1000, resultado}
  end

  def barra(v, pico), do: String.duplicate("#", max(1, round(v / pico * 40)))
end

esperado = Aula1.esperado()

IO.puts(String.duplicate("=", 62))
IO.puts("  PARADIGMAS DE PROGRAMACAO - AULA 1 - Elixir")
IO.puts("  Problema: somar os quadrados dos pares de 1 a 200.000")
IO.puts(String.duplicate("=", 62))
IO.puts("  Resultado esperado: #{esperado}\n")

medidas =
  [
    {"Pipeline |>", fn -> Aula1.pipeline() end},
    {"Compreensao", fn -> Aula1.compreensao() end},
    {"Recursao + match", fn -> Aula1.recursivo(Enum.to_list(1..200_000)) end},
    {"4 atores (spawn)", fn -> Aula1.por_atores(4) end}
  ]
  |> Enum.map(fn {nome, f} ->
    {ms, r} = Aula1.cronometrar(f)
    if r != esperado, do: raise("resultado divergente em #{nome}")
    {nome, ms}
  end)

pico = medidas |> Enum.map(&elem(&1, 1)) |> Enum.max()

IO.puts("  TEMPO DE EXECUCAO")

Enum.each(medidas, fn {nome, ms} ->
  nome_fmt = String.pad_trailing(nome, 18)
  ms_fmt = :erlang.float_to_binary(ms, decimals: 1) |> String.pad_leading(7)
  IO.puts("  #{nome_fmt} #{ms_fmt} ms  #{Aula1.barra(ms, pico)}")
end)

IO.puts("\n  Os quatro devolvem o MESMO numero.")
IO.puts("  O 4o usou 4 processos isolados: nenhuma memoria compartilhada,")
IO.puts("  nenhum lock, nenhuma condicao de corrida possivel (Aula 15).")
IO.puts("\n  >>> AMBIENTE ELIXIR OK <<<")
