-- =====================================================================
--  Paradigmas de Programação - Aula 1
--  Linguagem: Haskell      Plataforma online: https://play.haskell.org
--                          (também roda em Replit e OnlineGDB)
--  Haskell é a referência de funcional PURO das Aulas 4 e 5.
-- =====================================================================
module Main where

import Data.List (foldl')
import Text.Printf (printf)

dados :: [Int]
dados = [1 .. 200000]

esperado :: Int
esperado = sum [x * x | x <- dados, even x]

-- 1. COMPOSIÇÃO: filter, map e fold encadeados
funcional :: [Int] -> Int
funcional = foldl' (+) 0 . map (^ 2) . filter even

-- 2. COMPREENSÃO DE LISTA: a mesma ideia, sintaxe declarativa
compreensao :: [Int] -> Int
compreensao xs = sum [x * x | x <- xs, even x]

-- 3. RECURSÃO EXPLÍCITA com pattern matching e acumulador
--    Repare: NÃO existe atribuição. acc é um novo argumento a cada chamada.
recursivo :: [Int] -> Int
recursivo = go 0
  where
    go acc []     = acc
    go acc (x:xs)
      | even x    = go (acc + x * x) xs
      | otherwise = go acc xs

-- 4. PONTOFREE: nem os argumentos aparecem
pointfree :: [Int] -> Int
pointfree = sum . map (^ 2) . filter even

-- Gráfico em ASCII (sem biblioteca externa)
barra :: Int -> Int -> String
barra n maxN = replicate (max 1 (n * 40 `div` maxN)) '#'

main :: IO ()
main = do
  putStrLn (replicate 62 '=')
  putStrLn "  PARADIGMAS DE PROGRAMACAO - AULA 1 - Haskell"
  putStrLn "  Problema: somar os quadrados dos pares de 1 a 200.000"
  putStrLn (replicate 62 '=')
  printf "  Resultado esperado: %d\n\n" esperado

  let versoes = [ ("Composicao (.)",   funcional dados)
                , ("Compreensao",      compreensao dados)
                , ("Recursao + guarda", recursivo dados)
                , ("Pointfree",        pointfree dados) ]

  putStrLn "  VERIFICACAO: as quatro versoes devolvem o mesmo valor?"
  mapM_ (\(nome, v) ->
          printf "  %-20s %d  %s\n" nome v
                 (if v == esperado then "OK" else "DIVERGENTE")) versoes

  -- "gráfico" de complexidade sintática: linhas de código por versão
  let linhas = [("Composicao (.)", 1), ("Compreensao", 1),
                ("Recursao + guarda", 6), ("Pointfree", 1)] :: [(String, Int)]
      pico   = maximum (map snd linhas)
  putStrLn "\n  LINHAS DE CODIGO EFETIVAS"
  mapM_ (\(nome, n) -> printf "  %-20s %2d  %s\n" nome n (barra n pico)) linhas

  putStrLn "\n  Nenhuma variavel foi sobrescrita em nenhuma das versoes:"
  putStrLn "  em Haskell isso nem seria possivel. Estado observavel = zero."
  putStrLn "\n  >>> AMBIENTE HASKELL OK <<<"
