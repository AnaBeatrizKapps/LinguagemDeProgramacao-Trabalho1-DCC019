%%%%%%%%%%%%%%%%%%%%%%%%%%  ESTADO INICIAL  %%%%%%%%%%%%%%%%%%%%%%%%%%

insere(X,Lista,[X|Lista]).     %Insere um valor no inicio da lista

%Pra gerar uma linha, e preciso inserir um valor(0) N vezes dentro de um vetor
gera_linha(N,[]):-N=0,!.                                                                %Quando n for 0, o vetor esta vazio
gera_linha(N,Vetor):-N>0, N1 is N-1, insere(0, Vetor1, Vetor), gera_linha(N1,Vetor1).   %Decrementa o n e vai insere um 0 no vetor ate preencher todo com zeros

%Gera varias linhas, ou seja, gera o estado inicial. Entra com um N, N e retorna a matriz preenchida
gera_matriz(N,Linha,[]):-N>0, Linha=0, !.  %Cria e insere a primeira linha na matriz
gera_matriz(N,Linha,Matriz):-N>0, Linha>0, Linha1 is Linha-1, gera_linha(N,Vetor), insere(Vetor, Mat, Matriz), gera_matriz(N, Linha1, Mat).

%%%%%%%%%%%%%%%%%%%%%%%%%%% MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start:-leitura(N, Versao), inicia_jogo(N, Versao), !.  %Solicita leitura do tamanho do tabuleiro para depois iniciar o jogo

leitura(N, Versao):-repeat, dados_versao, read(Versao), member(Versao, [1, 2]), dados, read(N), N>0, !. %Repete a leitura enquanto o valor do N nao for maior que zero

limpa_tela:-write('\e[H\e[2J'). %Apaga os dados da tela

dados:-limpa_tela,
    write('Insira o valor de N(Dimensao do jogo), em que N>0:'), nl.

dados_versao:-limpa_tela, write('Escolha a versao do jogo. Normal(1) ou Simplificada(2): '), nl.

%Gera a matriz preenchida com 0(espacos em branco)
inicia_jogo(N, Versao):-
	(Versao =:= 1 -> VersaoEscolhida = inicia_jogo_versao_normal(N) ; VersaoEscolhida = inicia_jogo_versao_simplificada(N)),
	VersaoEscolhida.

inicia_jogo_versao_normal(N):-
	write('Iniciando Versao Normal...'),
    limpa_tela, gera_matriz(N+1, N, Matriz),
    limpa_tela, visualiza_estado(N, Matriz), jogo(N, Matriz).    %Mostra o estado inicial do jogo e inicia

inicia_jogo_versao_simplificada(N):-
	write('Iniciando Versao Simplificada...'),
    limpa_tela, gera_matriz(N+1, N, Matriz),
    limpa_tela, visualiza_estado(N, Matriz), jogoSimplificado(N, Matriz).    %Mostra o estado inicial do jogo e inicia


%%%%%%%%%%%%%%%%%%%%  VISUALIZA O ESTADO DO JOGO %%%%%%%%%%%%%%%%%%%%%

%Visualiza o estado atual da matriz
visualiza_estado(N, Matriz):-
	limpa_tela,
    nl, write('  '), gera_sequencia(N+1, 1, Sequencia), mostra_sequencia(Sequencia), nl,  %Mostra uma uma sequencia (1,2,3...,N)
	mostra_linhas(1,Matriz),                                                            %Imprime a matriz linha por linha
	write('  '), gera_sequencia(N+1, 1, Sequencia), mostra_sequencia(Sequencia), nl.      %Mostra uma uma sequencia (1,2,3...,N)

%Gera uma sequencia (1,2,3...,N)
gera_sequencia(N,_,[]):-N=0,!.
gera_sequencia(N,Inicio,Vetor):-N>0, N1 is N-1, Inicio1 is Inicio+1, insere(Inicio, Vetor1, Vetor), gera_sequencia(N1,Inicio1,Vetor1).

%Imprime a sequencia gerada
mostra_sequencia([]).
mostra_sequencia([Linha|Resto]):-imprime_valor(Linha), mostra_sequencia(Resto).

imprime_valor(V):-V<10, write('   '), write(V).
imprime_valor(V):-V=10, write('   '), write(V).
imprime_valor(V):-V>10, write('  '), write(V).

%Imprime todas as linhas
mostra_linhas(_,[]).                %Pra qualquer N(numero da linha), se a lista tiver vazia pare
mostra_linhas(N,[Linha|Resto]):-
	imprimeN(N), write(' |'),       %Escreve a referencia da linha atual
    mostra_linha(Linha),            %Escreve os dados da linha
    write(' '), write(N), nl,       %Da um espaco, escreve a referencia da linha atual e pula uma linha
	N1 is N+1,                      %Avanca o contador pra proxima linha
	mostra_linhas(N1, Resto).       %Recursao: manda imprimir o restante, ou seja, avanca pra proxima linha

imprimeN(N):-N<10, write(' '), write(N).
imprimeN(N):-N=10, write(N).
imprimeN(N):-N>10, write(N).

%Imprime cada elemento da linha lado a lado, um a um
mostra_linha([]).                                                           %Quando a lista estiver vazia pare
mostra_linha([Elemento|Resto]):-escreve(Elemento), mostra_linha(Resto).     %Escreve o elemento e passa pro proxima da mesma linha

escreve(0):-write('   |').    %Imprime vazio, pois 0 na matriz que representa vazio
escreve(1):-write(' X |').    %Impriem X, pois 1 na matriz que representa a jogada do player 1
escreve(2):-write(' O |').    %Imprime O, pois 2 na matriz representa a jogada do player 2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% JOGO - SIMPLIFICADO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Execucao do jogo simplificado
/* jogo simplificado loop */
jogoSimplificado(Matriz, _, _) :-
	board_gameover(Matriz),
	board_pretty_print(Matriz),
	board_score(Matriz, S),
	writeln(S),
	!.

jogoSimplificado(N, Matriz, 1, Diff) :-
	writeln('Insira o numero da coluna que deseja jogar: '),
	read(Move),
	Y = Move,                                      %X - Linha e Y - Coluna
	realiza_jogada_versao_simplificada(N, Matriz, Y, 1, Matriz1),
    visualiza_estado(N, Matriz1),
	testa_fim_de_jogo(N, Matriz1),
    jogoSimplificado(N, Matriz1, 2, Diff).
	

jogoSimplificado(N, Matriz, 2, Diff) :-
	writeln('IA esta `pensando`...'),
	generate_ai_decision(2, Matriz, Diff, [X, Y, _]),
	realiza_jogada(Matriz, X, Y, 2, NM),
	visualiza_estado(N, NM),
	testa_fim_de_jogo(N, NM),
	jogoSimplificado(N, NM, 1, Diff).


jogoSimplificado(N, Matriz):-
    Diff is 1,
    jogoSimplificado(N, Matriz, 1, Diff).                   %Solicita a posicao em que o 1 quer jogar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% JOGO - NORMAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Execucao do jogo
/* jogo loop */
jogo(Matriz, _, _) :-
	board_gameover(Matriz),
	board_pretty_print(Matriz),
	board_score(Matriz, S),
	writeln(S),
	!.

jogo(N, Matriz, 1, Diff) :-
	writeln('Insira seu movimento ([X, Y].): '),
	read(Move),
	[X, Y] = Move,                                      %X - Linha e Y - Coluna
	realiza_jogada(Matriz, X, Y, 1, Matriz1),
    visualiza_estado(N, Matriz1),
	testa_fim_de_jogo(N, Matriz1),
    jogo(N, Matriz1, 2, Diff).
	

jogo(N, Matriz, 2, Diff) :-
	writeln('IA esta `pensando`...'),
	generate_ai_decision(2, Matriz, Diff, [X, Y, _]),
	realiza_jogada(Matriz, X, Y, 2, NM),
	visualiza_estado(N, NM),
	testa_fim_de_jogo(N, NM),
	jogo(N, NM, 1, Diff).


jogo(N, Matriz):-
    Diff is 1,
    jogo(N, Matriz, 1, Diff).                   %Solicita a posicao em que o 1 quer jogar


%%%%%%%%%%%%%%%%%%%% VERIFICA FIM DE JOGO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Testa se o jogo deve continuar ou nao 
testa_fim_de_jogo(N, Matriz):-
    not(verifica_fim_de_jogo(N, Matriz));  %Verifica fim de jogo sempre retorna true se o jogo deve continuar. Caso retorne false, cai pra linha de baixo
    mostra_ganhador(N, Matriz), !, halt.    %Imprime o estado final do jogo e quem ganhou, alem de parar o jogo

%Imprime o estado final do jogo e quem ganhou
mostra_ganhador(N, Matriz):-
    verifica_ganhador(N, Matriz, JogadorGanhador),                  %Descobre quem e o ganhador
    visualiza_estado(N, Matriz),     %Imprime o estado final do jogo
    mostra_jogador(JogadorGanhador).    %Imprime quem ganhou o jogo

%Imprime quem ganhou
mostra_jogador(Id):-
    Id=0, nl, write('Empate'), nl.
mostra_jogador(Id):-
    Id=1, nl, write('Voce ganhou!'), nl.
mostra_jogador(Id):-
    Id=2, nl, write('Computador ganhou!'), nl.

%%%%%%%%%%%%%%%%%%%%% CAPTURA O VALOR DE UMA POSICAO DA MATRIZ  %%%%%%%%%%%%%%%%%%%%%%

%Pega uma linha da matriz
get_linha(Cont, Indice, [H|_], H):- Indice=Cont, !.
get_linha(Cont, Indice, [_|T], R):- Cont1 is Cont+1, get_linha(Cont1, Indice, T, R).

%Pega um elemento da linha da matriz
get_elemento_da_linha(Cont, Indice, [H|_], H):- Indice=Cont, !.
get_elemento_da_linha(Cont, Indice, [_|T], R):- Cont1 is Cont+1, get_elemento_da_linha(Cont1, Indice, T, R).

%Pega um elemento de um posicao da matriz
get_posicao(Matriz, LinhaProcurada, ColunaProcurada, ElementoEncontrado):-
    get_linha(1, LinhaProcurada, Matriz, R), get_elemento_da_linha(1, ColunaProcurada, R, ElementoEncontrado).


%%%%%%%%%%%%%%%%%%%%% ATUALIZA O VALOR DE UMA POSICAO DA MATRIZ - JOGADA  %%%%%%%%%%%%%

%Seta na matriz aquela posicao(X,Y) o valor do player (1 ou 2 - X ou O respectivamente)
set_posicao([_|T], 1, Jogador, [Jogador|T]):-!.
set_posicao([H|T], Indice, Jogador, [H|R]):- Indice>0, Indice1 is Indice-1, set_posicao(T, Indice1, Jogador, R).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% REALIZA JOGADA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

realiza_jogada(Matriz, X, Y, Jogador, NovaMatriz) :-
    get_linha(1, X, Matriz, R),    %Pega a linha em que se esta realizando a jogada          
    set_posicao(R, Y, Jogador, NovaLinha),             %Atualiza a lista correspondente a aquela linha
    set_posicao(Matriz, X, NovaLinha, NovaMatriz), !.   %Atualiza a lista de listas - Coloca a linha atualizada

set_coluna(Matriz, X, Y, Jogador, NovaMatriz) :-
	get_linha(1, X, Matriz, R),    %Pega a linha em que se esta realizando a jogada          
    set_posicao(R, Y, Jogador, NovaLinha),             %Atualiza a lista correspondente a aquela linha
    set_posicao(Matriz, X, NovaLinha, NovaMatriz), !.   %Atualiza a lista de listas - Coloca a linha atualizada

realiza_jogada_versao_simplificada(N, Matriz, Y, Jogador, NovaMatriz) :-
    get_posicao(Matriz, N, Y, ElementoEncontrado),
    (ElementoEncontrado =:= 0 ->
        set_coluna(Matriz, N, Y, Jogador, NovaMatriz),
		!
    ;
        N > 1,
        NDecrementado is N - 1,
        realiza_jogada_versao_simplificada(NDecrementado, Matriz, Y, Jogador, NovaMatriz)
    ).

realiza_jogada_versao_simplificada(_, _, _, _, _) :-
    fail.


%%%%%%%%%%%%%%%%%%%%%%%%% VALIDA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Verifica o fim de jogo. Nao e necessario saber quem ganhou
verifica_fim_de_jogo(N, Matriz):-
    verifica_ganhador(N, Matriz, _), !.

%Verifica o fim de jogo pelas condicoes abaixo e retorna o ganhador
verifica_ganhador(N, Matriz, JogadorGanhador):-
    verifica_fim_de_jogo_pela_linha(N, Matriz, JogadorGanhador), !;                 %Testa se existe alguma linha toda preenchida por 1 ou 2
    verifica_fim_de_jogo_pela_coluna(N, Matriz, JogadorGanhador), !;                %Testa se existe alguma coluna toda preenchida por 1 ou 2
    verifica_fim_de_jogo_pela_diagonal_principal(N, Matriz, JogadorGanhador), !;    %Testa se a diagonal principal esta toda preenchida por 1 ou 2
    verifica_fim_de_jogo_pela_diagonal_secundaria(N+1, Matriz, JogadorGanhador), !;   %Testa se a diagonal secundaria esta toda preenchida por 1 ou 2
    verifica_fim_de_jogo_deu_velha(N, Matriz, JogadorGanhador), !.                  %Testa se a matriz esta toda preenchida - Nao existe nenhum valor 0 (Lugar vazio)

%Verifica se um elemento e um membro de uma lista
membro(X,[X|_]):-!.
membro(X,[_|T]):-membro(X,T).

n_consecutivos(_, [], 0).
n_consecutivos(X, [X | T], N) :- 
    n_consecutivos(X, T, N1), 
    N is N1 + 1.
n_consecutivos(X, [_ | T], 0) :- n_consecutivos(X, T, 0).

n_consecutivos_lista(_, [], 0).
n_consecutivos_lista(X, L, N) :-
    append(_, Suffix, L),
    append(Prefix, [X | _], Suffix),
    length(Prefix, M),
    n_consecutivos(X, Prefix, M1),
    N is max(M1, M),
    N >= N.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LINHA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Testa se tem alguma linha com todos valores 1 ou 2 (X ou O respectivamente)
verifica_fim_de_jogo_pela_linha(N, Matriz, 1):-testa_1_linha(N, 1, Matriz), !.  %Testa se existe alguma linha em que em que há N elementos de 1 consecutivos, a partir da linha 1
verifica_fim_de_jogo_pela_linha(N, Matriz, 2):-testa_2_linha(N, 1, Matriz), !.  %Testa se existe alguma linha em que há N elementos de 2 consecutivos, a partir da linha 1

%Testa se existe alguma linha em que todos elementos sao 1
testa_1_linha(N, Linha, Matriz):-
    get_linha(1, Linha, Matriz, R),                         %Pega a linha
    n_consecutivos(1, R,N), !.  %Testa se a linha tem três elementos 1 consecutivos e não tem 0 nem 2
%Recursao - Passa pra proxima linha
testa_1_linha(N, Linha, Matriz):-
    (Linha<N; Linha=N),
    Linha1 is Linha+1,
    testa_1_linha(N, Linha1, Matriz), !.

%Testa se existe alguma linha em que todos elementos sao 2
testa_2_linha(N, Linha, Matriz):-
    get_linha(1, Linha, Matriz, R),                         %Pega a linha
    n_consecutivos(2, R,N), !.  %Testa se a linha tem três elementos 2 consecutivos e não tem 0 nem 1
%Recursao - Passa pra proxima linha
testa_2_linha(N, Linha, Matriz):-
    (Linha<N; Linha=N),
    Linha2 is Linha+1,
    testa_2_linha(N, Linha2, Matriz), !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% COLUNA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Testa se tem alguma coluna com todos valores 1 ou 2 (X ou O respectivamente)
verifica_fim_de_jogo_pela_coluna(N, Matriz, 1):-testa_1_colunas(N, Matriz, 1, 1), !.    %Testa se existe alguma coluna em que há N elementos de 1 consecutivos
verifica_fim_de_jogo_pela_coluna(N, Matriz, 2):-testa_2_colunas(N, Matriz, 1, 1), !.    %Testa se existe alguma coluna em que há N elementos de 2 consecutivos

%Testa todas colunas buscando algum elemento diferente de 1
testa_1_colunas(N, Matriz, Linha, Coluna):-
    (Coluna<N; Coluna=N),
    Coluna1 is Coluna+1,
    (not(testa_1_coluna(N, Matriz, Linha, Coluna)); testa_1_colunas(N, Matriz, Linha, Coluna1)), !. %Se nao encontrou, passa pra proxima coluna

%Testa cada coluna buscando algum elemento diferente de 1
testa_1_coluna(_, Matriz, Linha, Coluna):-
    get_posicao(Matriz, Linha, Coluna, ElementoEncontrado),     %Pega o elemento da matriz correspondente aquela posicao (linha, coluna)
    ElementoEncontrado\=1, !.                                   %Testa se existe algum elemento diferente de 1
%Recursao - Passa pra proxima linha
testa_1_coluna(N, Matriz, Linha, Coluna):-
    (Linha<N; Linha=N),
    Linha1 is Linha+1,
    testa_1_coluna(N, Matriz, Linha1, Coluna).

%Testa todas colunas buscando algum elemento diferente de 2
testa_2_colunas(N, Matriz, Linha, Coluna):-
    (Coluna<N; Coluna=N),
    Coluna2 is Coluna+1,
    (not(testa_2_coluna(N, Matriz, Linha, Coluna)); testa_2_colunas(N, Matriz, Linha, Coluna2)), !. %Se nao encontrou, passa pra proxima coluna

%Testa cada coluna buscando algum elemento diferente de 2
testa_2_coluna(_, Matriz, Linha, Coluna):-
    get_posicao(Matriz, Linha, Coluna, ElementoEncontrado),     %Pega o elemento da matriz correspondente aquela posicao (linha, coluna)
    ElementoEncontrado\=2, !.                                   %Testa se existe algum elemento diferente de 2
%Recursao - Passa pra proxima linha
testa_2_coluna(N, Matriz, Linha, Coluna):-
    (Linha<N; Linha=N),
    Linha2 is Linha+1,
    testa_2_coluna(N, Matriz, Linha2, Coluna).

%%%%%%%%%%%%%%%%%%%%%%%% DIAGONAL PRINCIPAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Testa se tem alguma diagonal principal com todos valores 1 ou 2 (X ou O respectivamente)
verifica_fim_de_jogo_pela_diagonal_principal(N, Matriz, 1):-not(testa_1_diagonal_principal(N, Matriz, 1, 1)), !. %Testa se nao encontrou nenhum 0 ou 2 - So tem 1
verifica_fim_de_jogo_pela_diagonal_principal(N, Matriz, 2):-not(testa_2_diagonal_principal(N, Matriz, 1, 1)), !. %Testa se nao encontrou nenhum 0 ou 1 - So tem 2

testa_1_diagonal_principal(_, Matriz, Linha, Coluna):-
    get_posicao(Matriz, Linha, Coluna, ElementoEncontrado), %Pega o elemento da matriz correspondente aquela posicao (linha, coluna)
    (ElementoEncontrado=0; ElementoEncontrado=2), !.        %Tenta encontrar algum 0 ou 2. Se nao achar, e porque so tem 1
%Recursao - Avanca uma linha e uma coluna, ja que se esta andando na diagonal principal
testa_1_diagonal_principal(N, Matriz, Linha, Coluna):-
    (Linha<N; Linha=N), (Coluna<N; Coluna=N),
    Linha1 is Linha+1, Coluna1 is Coluna+1,
    testa_1_diagonal_principal(N, Matriz, Linha1, Coluna1).

testa_2_diagonal_principal(_, Matriz, Linha, Coluna):-
    get_posicao(Matriz, Linha, Coluna, ElementoEncontrado), %Pega o elemento da matriz correspondente aquela posicao (linha, coluna)
    (ElementoEncontrado=0; ElementoEncontrado=1), !.        %Tenta encontrar algum 0 ou 1. Se nao achar, e porque so tem 2
%Recursao - Avanca uma linha e uma coluna, ja que se esta andando na diagonal principal
testa_2_diagonal_principal(N, Matriz, Linha, Coluna):-
    (Linha<N; Linha=N), (Coluna<N; Coluna=N),
    Linha2 is Linha+1, Coluna2 is Coluna+1,
    testa_2_diagonal_principal(N, Matriz, Linha2, Coluna2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DIAGONAL SECUNDARIA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Testa se tem alguma diagonal secundaria com todos valores 1 ou 2 (X ou O respectivamente)
verifica_fim_de_jogo_pela_diagonal_secundaria(N, Matriz, 1):-not(testa_1_diagonal_secundaria(N, Matriz, 1, N)), !. %Testa se nao encontrou nenhum 0 ou 2 - So tem 1
verifica_fim_de_jogo_pela_diagonal_secundaria(N, Matriz, 2):-not(testa_2_diagonal_secundaria(N, Matriz, 1, N)), !. %Testa se nao encontrou nenhum 0 ou 1 - So tem 2

testa_1_diagonal_secundaria(_, Matriz, Linha, Coluna) :-
    get_posicao(Matriz, Linha, Coluna, ElementoEncontrado),
    (ElementoEncontrado = 0 ; ElementoEncontrado = 2), !.
testa_1_diagonal_secundaria(N, Matriz, Linha, Coluna) :-
    Linha =< N,
    Coluna > 0,
    Linha1 is Linha + 1,
    Coluna1 is Coluna - 1,
    testa_1_diagonal_secundaria(N, Matriz, Linha1, Coluna1).

testa_2_diagonal_secundaria(_, Matriz, Linha, Coluna) :-
    get_posicao(Matriz, Linha, Coluna, ElementoEncontrado),
    (ElementoEncontrado = 0 ; ElementoEncontrado = 1), !.
testa_2_diagonal_secundaria(N, Matriz, Linha, Coluna) :-
    Linha =< N,
    Coluna > 0,
    Linha2 is Linha + 1,
    Coluna2 is Coluna - 1,
    testa_2_diagonal_secundaria(N, Matriz, Linha2, Coluna2).

%%%%%%%%%%%%%%%%%%%%%%%%  VELHA  - EMPATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Testa se deu velha
verifica_fim_de_jogo_deu_velha(N, Matriz, 0):-not(testa_0_linha(N, 1, Matriz)), !.  %Testa se nao encontrou nenhum 0 - Se nao existe lugar vazio na matriz

testa_0_linha(_, Linha, Matriz):-
    get_linha(1, Linha, Matriz, R), %Pega uma linha
    membro(0, R), !.                %Tenta encontrar algum 0 na linha. Se nao achar, e porque so tem 1 ou 2
%Recursao - Avanca pra proxima linha
testa_0_linha(N, Linha, Matriz):-
    (Linha<N; Linha=N),
    Linha0 is Linha+1,
    testa_0_linha(N, Linha0, Matriz), !.


%%%%%%%%%%%%%%%%%%%%%% DECISÃO IA - USANDO MINIMAX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/* some matrix standard functions, maybe use another file? */

/* concat, flat: some old implemented function i found on my notes */
concat([], L, L).
concat([H | T], L2, [H | L]) :-
	concat(T, L2, L).


flat([], []) :-
	!.
	
flat(A, [A]) :-
	atomic(A).

flat([H | T], R) :-
	flat(H, V),
	flat(T, T2),
	concat(V, T2, R).
	
/* returns the number of occurance of E inside of the vector */
vector_count([], _, 0).

vector_count([E | T], E, Count) :-
	vector_count(T, E, NewCount),
	Count is NewCount + 1,
	!.
	
vector_count([H | T], E, Count) :-
	H \= E,
	vector_count(T, E, Count).
	
/* returns the length of a vector. be careful, it's not tail-recursive */
vector_size([], 0).
vector_size([_ | T], S) :-
	vector_size(T, NS),
	S is NS + 1.

/* checks if two vectors are equal: vector_equals([1,2,3], [1,2,3]) */
vector_equals([], []) :-
	!.

vector_equals([H | VT], [H | WT]) :-
	vector_equals(VT, WT).
	
/* sets the i-th element of a prolog list: vector_set(list, position, new value, new list) */
vector_set([_ | T], 1, V, [V | T]) :-
	!.

vector_set([H | T], X, V, [H | NL]) :-
	Y is X - 1,
	vector_set(T, Y, V, NL).

/* ... */
vector_append([], X, [X]) :-
	!.
	
vector_append([H | T], X, [H | NT]) :-
	vector_append(T, X, NT).

/* ... */
vector_get([H | _], 1, H) :-
	!.
	
vector_get([_ | T], I, V) :-
	J is I - 1,
	vector_get(T, J, V).

/* ... */	
vector_contains([H | _], H).

vector_contains([_ | T], H) :-
	vector_contains(T, H).
	
/* returns the shape of the matrix: matrix_shape(InputMatrix, Rows, Columns) */
matrix_shape(M, X, Y) :-
	vector_size(M, X),
	X == 0,
	!,
	Y = 0.
	
matrix_shape(M, X, Y) :-
	vector_size(M, X),
	matrix_get_row(M, 1, R),
	vector_size(R, Y).
	
/* matrix_set_row(matrix, row index, new row, new matrix) */
matrix_set_row([_ | T], 1, R, [R | T]) :-
	!.
	
matrix_set_row([H | T], I, R, [H | M]) :-
	J is I - 1,
	matrix_set_row(T, J, R, M).
	
/* matrix_get_row(matrix, row index, row) */
matrix_get_row([R | _], 1, R) :-
	!.
	
matrix_get_row([_ | M], I, R) :-
	J is I - 1,
	matrix_get_row(M, J, R).

/* ... */	
matrix_get_column([], _, []).
	
matrix_get_column([R | M], I, [C | X]) :-
	vector_get(R, I, C),
	matrix_get_column(M, I, X).
	
matrix_diag(M, D) :-
	matrix_diag(M, D, 1).

matrix_diag([], [], _).

matrix_diag([R | M], [C | D], I) :-
		vector_get(R, I, C),
		J is I + 1,
		matrix_diag(M, D, J).
		
matrix_rdiag(M, D) :-
	matrix_shape(M, Rows, _),
	matrix_rdiag(M, D, Rows).
	
matrix_rdiag([], [], _).

matrix_rdiag([R | M], [C | D], I) :-
	vector_get(R, I, C),
	J is I - 1,
	matrix_rdiag(M, D, J).
	
matrix_transpose(M, M2) :-
	matrix_shape(M, _, Columns),
	matrix_transpose(M, M2, 1, Columns).
	
matrix_transpose([], [], _, _).

matrix_transpose(_, [], ColumnIndex, MaxIndex) :-
	ColumnIndex > MaxIndex,
	!.

matrix_transpose(M, [C | X], ColumnIndex, MaxIndex) :-
	ColumnIndex =< MaxIndex,
	!,
	NextIndex is ColumnIndex + 1,
	matrix_get_column(M, ColumnIndex, C),
	matrix_transpose(M, X, NextIndex, MaxIndex).

/* sets a single cell of a matrix: matrix_set(Matrix, i, j, value, Returned New Matrix) */
matrix_set(M, X, Y, V, NM) :-
	matrix_get_row(M, X, R),
	vector_set(R, Y, V, NR),
	matrix_set_row(M, X, NR, NM).
	

/* statically defined winning vectors */
win(2, [2, 2, 2]).
win(1, [1, 1, 1]). 

/* pretty print symbols */
symbol(0, '   ').
symbol(2, ' O ').
symbol(1, ' X ').

board_pretty_print([]) :-
	writeln(' ').

board_pretty_print([R | M]) :-
	board_pretty_print_row(R),
	writeln(' '),
	board_pretty_print(M).
	
board_pretty_print_row([]).
	
board_pretty_print_row([C | R]) :-
	symbol(C, X),
	write(X),
	write(' '),
	board_pretty_print_row(R).

board_next_turn(2, 1).
board_next_turn(1, 2).

board_make_move(B, X, Y, Value, NB) :-
	matrix_set(B, X, Y, Value, NB).
 
/* game over if all cells are filled */
board_gameover(B) :-
	flat(B, X),
	not(vector_contains(X, 0)),
	!.

/* game over if the diag is a win */
board_gameover(B) :- 
	matrix_diag(B, D),
	board_gameover_condition(D),
	!.

/* could have done so, but i've tried to keep the board functions shape-indipendent, for what it's worth
board_gameover([ [C, _, _], [_, C, _], [_, _, C] ]) :-
	C \= 0.
	*/
	
board_gameover(B) :-
	matrix_rdiag(B, D2),
	board_gameover_condition(D2),
	!.	
	
/* game over if a row is a win */
board_gameover(B) :-
	board_gameover_rows(B),
	!.

/* game over if a column is a win */
board_gameover(B) :-
	matrix_transpose(B, M),
	board_gameover_rows(M),
	!.
	
board_gameover_rows([R | _]) :-
	board_gameover_condition(R).
	
board_gameover_rows([_ | B]) :-
	board_gameover_rows(B).
	
/* checks if a vector is a `winning` one */
board_gameover_condition(R) :-
	win(1, V),
	vector_equals(R, V).
	
board_gameover_condition(R) :-
	win(2, V),
	vector_equals(R, V).

/* returns the score (heuristic) of the board */
board_score(B, Score) :-
	matrix_diag(B, D),
	matrix_rdiag(B, D2),
	board_rows_score(B, RowsScore),
	board_columns_score(B, ColumnsScore),
	board_row_score(D, DiagScore),
	board_row_score(D2, Diag2Score),
	Score is DiagScore + Diag2Score + RowsScore + ColumnsScore.
	
board_rows_score([], 0).
	
board_rows_score([R | M], Score) :-
	board_row_score(R, S),
	board_rows_score(M, SS),
	Score is SS + S.
	
board_columns_score(B, Score) :-
	matrix_transpose(B, M),
	board_rows_score(M, Score).

board_row_score(R, Score) :-
	vector_count(R, 1, 0),
	vector_count(R, 2, ScoreAI),
	ScoreAI > 0,
	Exponent is ScoreAI - 1,
	pow(10, Exponent, Score),
	!.

board_row_score(R, Score) :-
	vector_count(R, 2, 0),
	vector_count(R, 1, ScoreHuman),
	ScoreHuman > 0,
	Exponent is ScoreHuman - 1,
	pow(10, Exponent, S),
	Score is -S,
	!.

board_row_score(_, 0).

/* returns a list of possible moves */
board_free_cells(B, C) :-
	matrix_shape(B, Rows, Columns),
	board_free_cells(B, Rows, Columns, C).
	
board_free_cells(_, 0, _, []) :-
	!.

board_free_cells(Board, RowIndex, 0, Cells) :-
	matrix_shape(Board, _, Columns),
	NRowIndex is RowIndex - 1,
	board_free_cells(Board, NRowIndex, Columns, Cells).

board_free_cells(Board, RowIndex, ColumnIndex, [[RowIndex, ColumnIndex] | Rest]) :-
	matrix_get_row(Board, RowIndex, Row),
	vector_get(Row, ColumnIndex, 0),
	NColumnIndex is ColumnIndex - 1,
	board_free_cells(Board, RowIndex, NColumnIndex, Rest),
	!.
	
board_free_cells(Board, RowIndex, ColumnIndex, Cells) :-
	/* we know that cell != 0 */
	NColumnIndex is ColumnIndex - 1,
	board_free_cells(Board, RowIndex, NColumnIndex, Cells),
	!.
	
generate_ai_decision_max([[X, Y, Score]], [X, Y, Score]).
	
generate_ai_decision_max([[_, _, Score] | Scores], Max) :-
	generate_ai_decision_max(Scores, [Xm, Ym, ScoreM]),
	ScoreM > Score,
	Max = [Xm, Ym, ScoreM],
	!.
	
generate_ai_decision_max([[X, Y, Score] | Scores], Max) :-
	generate_ai_decision_max(Scores, [_, _, _]),
	Max = [X, Y, Score].	
	
generate_ai_decision_min([[X, Y, Score]], [X, Y, Score]).
	
generate_ai_decision_min([[_, _, Score] | Scores], Min) :-
	generate_ai_decision_min(Scores, [Xm, Ym, ScoreM]),
	ScoreM < Score,
	Min = [Xm, Ym, ScoreM],
	!.
	
generate_ai_decision_min([[X, Y, Score] | Scores], Min) :-
	generate_ai_decision_min(Scores, [_, _, _]),
	Min = [X, Y, Score].

generate_ai_decision(_, B, 0, [0, 0, S]) :-
	board_score(B, S),
	!.

generate_ai_decision(_, B, _, [0, 0, S]) :-
	board_gameover(B),
	board_score(B, S),
	!.
	
generate_ai_decision(2, B, Depth, Decision) :-
	board_free_cells(B, Cells),
	generate_ai_decision_recursion(2, B, Depth, Cells, Scores),
	generate_ai_decision_max(Scores, Decision),
	!.

generate_ai_decision(1, B, Depth, Decision) :-
	board_free_cells(B, Cells),
	generate_ai_decision_recursion(1, B, Depth, Cells, Scores),
	generate_ai_decision_min(Scores, Decision).
	
generate_ai_decision_recursion(_, _, _, [], []).
	
generate_ai_decision_recursion(Turn, B, Depth, [[X, Y] | T], [[X, Y, Decision] | Scores]) :-
	D is Depth - 1,
	board_make_move(B, X, Y, Turn, NB),
	board_next_turn(Turn, NextTurn),
	generate_ai_decision(NextTurn, NB, D, [_, _, Decision]),
	generate_ai_decision_recursion(Turn, B, Depth, T, Scores).