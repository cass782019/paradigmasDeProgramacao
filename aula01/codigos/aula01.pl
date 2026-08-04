% =====================================================================
%  Paradigmas de Programacao - Aula 1
%  Linguagem: SWI-Prolog   Plataforma online: https://swish.swi-prolog.org
%  Rode no terminal com:   swipl -g main -t halt aula01.pl
%  No SWISH, cole tudo e digite a consulta:   ?- main.
% =====================================================================

% --- 1. RECURSAO SOBRE LISTAS: sem laco, sem atribuicao --------------
%     A relacao soma_quadrados_pares(Lista, Total) e verdadeira quando
%     Total e a soma dos quadrados dos pares de Lista.
soma_quadrados_pares([], 0).
soma_quadrados_pares([X|Resto], Total) :-
    0 is X mod 2, !,
    soma_quadrados_pares(Resto, Parcial),
    Total is Parcial + X * X.
soma_quadrados_pares([_|Resto], Total) :-
    soma_quadrados_pares(Resto, Total).

% --- 2. GERACAO E TESTE com findall: o estilo mais declarativo -------
por_findall(N, Total) :-
    findall(Q, (between(1, N, X), 0 is X mod 2, Q is X * X), Quadrados),
    sum_list(Quadrados, Total).

% --- 3. AGREGACAO DIRETA: uma linha, puro "o que" --------------------
por_aggregate(N, Total) :-
    aggregate_all(sum(Q), (between(1, N, X), 0 is X mod 2, Q is X * X), Total).

% --- 4. RELACOES SAO BIDIRECIONAIS: o que nenhuma funcao faz ---------
%     A mesma relacao responde perguntas em direcoes diferentes.
progenitor(joao, maria).
progenitor(joao, pedro).
progenitor(maria, ana).
progenitor(pedro, bruno).

avo(A, N) :- progenitor(A, P), progenitor(P, N).

% --- Grafico em ASCII -------------------------------------------------
barra(0, '') :- !.
barra(N, Barra) :- N > 0, length(L, N), maplist(=('#'), L), atomic_list_concat(L, Barra).

linha_grafico(Nome, Valor, Pico) :-
    Larg is max(1, round(Valor / Pico * 40)),
    barra(Larg, B),
    format("  ~w~t~20| ~t~1f~7+ ms  ~w~n", [Nome, Valor, B]).

cronometrar(Meta, Ms) :-
    get_time(T0), call(Meta), get_time(T1), Ms is (T1 - T0) * 1000.

main :-
    N = 200000,
    numlist(1, N, Lista),
    format("==============================================================~n"),
    format("  PARADIGMAS DE PROGRAMACAO - AULA 1 - SWI-Prolog~n"),
    format("  Problema: somar os quadrados dos pares de 1 a ~d~n", [N]),
    format("==============================================================~n"),
    por_aggregate(N, Esperado),
    format("  Resultado esperado: ~d~n~n", [Esperado]),

    cronometrar(soma_quadrados_pares(Lista, R1), T1),
    cronometrar(por_findall(N, R2), T2),
    cronometrar(por_aggregate(N, R3), T3),
    ( R1 =:= Esperado, R2 =:= Esperado, R3 =:= Esperado
    -> true ; format("  ATENCAO: resultados divergentes!~n") ),

    Pico is max(T1, max(T2, T3)),
    format("  TEMPO DE EXECUCAO~n"),
    linha_grafico('Recursao + corte', T1, Pico),
    linha_grafico('findall/3', T2, Pico),
    linha_grafico('aggregate_all/3', T3, Pico),

    format("~n  RELACOES SAO BIDIRECIONAIS (o que nenhuma funcao faz):~n"),
    findall(X-Y, avo(X, Y), Pares),
    format("    quem e avo de quem?      ~w~n", [Pares]),
    findall(A, avo(A, ana), Avos),
    format("    quem e avo de ana?       ~w~n", [Avos]),
    findall(Nt, avo(joao, Nt), Netos),
    format("    quem sao os netos de joao? ~w~n", [Netos]),

    format("~n  A MESMA regra avo/2 respondeu tres perguntas diferentes.~n"),
    format("  Em Prolog voce declara a relacao; a busca e do interpretador.~n"),
    format("~n  >>> AMBIENTE SWI-PROLOG OK <<<~n").
