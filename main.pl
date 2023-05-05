%%%%%%%%%%%%%%%%%%%%%%%%%%  ESTADO INICIAL  %%%%%%%%%%%%%%%%%%%%%%%%%%

%Insere um valor no inicio da lista
insere(X,Lista,[X|Lista]).     

%Pra gerar uma linha, e preciso inserir um valor(0) N vezes dentro de um vetor
%Quando n for 0, o vetor esta vazio
gera_linha(N,[]):-N=0,!.  

%Decrementa o n e vai insere um 0 no vetor ate preencher todo com zeros                                                             
gera_linha(N,Vetor):-N>0, N1 is N-1, insere(0, Vetor1, Vetor), gera_linha(N1,Vetor1).   

%Gera varias linhas, ou seja, gera o estado inicial do tabuleiro. Entra com um N_Colunas(numero de colunas), N_Linhas(numero de linhas) e retorna a matriz preenchida
%Quando o numero de linhas for 0, a matriz esta vazia
gera_matriz(N_Colunas,N_Linhas,[]):-N_Colunas>0, N_Linhas=0, !.  

%Esse predicado e para preencher toda a matriz com 0
gera_matriz(N_Colunas,N_Linhas,Matriz):-N_Colunas>0, N_Linhas>0, N_Linhas1 is N_Linhas-1, gera_linha(N_Colunas,Vetor), insere(Vetor, Mat, Matriz), gera_matriz(N_Colunas, N_Linhas1, Mat).

%%%%%%%%%%%%%%%%%%%%%%%%%%% MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Solicita leitura do tamanho do tabuleiro para depois iniciar o jogo
start:-leitura(N, Versao), inicia_jogo(N, Versao), !. 

%Repete a leitura enquanto o valor da versao nao estiver na lista [1,2] e N nao for maior que zero
leitura(N, Versao):-repeat, solicita_versao, read(Versao), member(Versao, [1, 2]), solicita_dimensao, read(N), N>0, !. 

%Apaga os dados da tela
limpa_tela:-write('\e[H\e[2J'). 

solicita_dimensao:-limpa_tela,
    write('Insira o valor de N(Dimensao do jogo), em que N>0:'), nl.

solicita_versao:-limpa_tela, write('Escolha a versao do jogo. Normal(1) ou Simplificada(2): '), nl.

%Gera a matriz preenchida com 0(espacos em branco)
inicia_jogo(N, Versao):-
	(Versao = 1 -> VersaoEscolhida = inicia_jogo_versao_normal(N) ; VersaoEscolhida = inicia_jogo_versao_simplificada(N)),
	VersaoEscolhida.

inicia_jogo_versao_normal(N):-
	write('Iniciando Versao Normal...'),
    limpa_tela, gera_matriz(N+1, N, Matriz),
	%Mostra o estado inicial do jogo e inicia
    visualiza_estado(N, Matriz), jogo(N, Matriz).    

inicia_jogo_versao_simplificada(N):-
	write('Iniciando Versao Simplificada...'),
    limpa_tela, gera_matriz(N+1, N, Matriz),
	%Mostra o estado inicial do jogo e inicia
    visualiza_estado(N, Matriz), jogoSimplificado(N, Matriz).    


%%%%%%%%%%%%%%%%%%%%  VISUALIZA O ESTADO DO JOGO %%%%%%%%%%%%%%%%%%%%%

%Visualiza o estado atual da matriz
visualiza_estado(N, Matriz):-
	limpa_tela,
	%Mostra uma uma sequencia (1,2,3...,N)
    nl, write('  '), gera_sequencia(N+1, 1, Sequencia), mostra_sequencia(Sequencia), nl,  
	%Imprime a matriz linha por linha
	mostra_linhas(1,Matriz),    
	%Mostra uma uma sequencia (1,2,3...,N)                                                        
	write('  '), gera_sequencia(N+1, 1, Sequencia), mostra_sequencia(Sequencia), nl.      

%Gera uma sequencia (1,2,3...,N)
gera_sequencia(N,_,[]):-N=0,!.
gera_sequencia(N,Inicio,Vetor):-N>0, N1 is N-1, Inicio1 is Inicio+1, insere(Inicio, Vetor1, Vetor), gera_sequencia(N1,Inicio1,Vetor1).

%Imprime a sequencia gerada
mostra_sequencia([]).
mostra_sequencia([Linha|Resto]):-imprime_valor(Linha), mostra_sequencia(Resto).

imprime_valor(V):-V=<10, write('   '), write(V).
imprime_valor(V):-V>10, write('  '), write(V).

%Imprime todas as linhas
%Pra qualquer N(numero da linha), se a lista tiver vazia pare
mostra_linhas(_,[]).                
mostra_linhas(N,[Linha|Resto]):-
	%Escreve a referencia da linha atual
	imprimeN(N), write(' |'),  
	%Escreve os dados da linha     
    mostra_linha(Linha),  
	%Da um espaco, escreve a referencia da linha atual e pula uma linha          
    write(' '), write(N), nl,   
	%Avanca o contador pra proxima linha    
	N1 is N+1,   
	%Recursao: manda imprimir o restante, ou seja, avanca pra proxima linha                   
	mostra_linhas(N1, Resto).       

imprimeN(N):-N<10, write(' '), write(N).
imprimeN(N):-N>=10, write(N).

%Imprime cada elemento da linha lado a lado, um a um
%Quando a lista estiver vazia pare
mostra_linha([]).    
%Escreve o elemento e passa pro proxima da mesma linha                                                       
mostra_linha([Elemento|Resto]):-escreve(Elemento), mostra_linha(Resto).     

%Imprime vazio, pois 0 na matriz que representa vazio
escreve(0):-write('   |').    
%Imprime X, pois 1 na matriz que representa a jogada do player 1
escreve(1):-write(' X |'). 
%Imprime O, pois 2 na matriz representa a jogada do player 2   
escreve(2):-write(' O |').    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% JOGO - SIMPLIFICADO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Execucao do jogo simplificado

jogoSimplificado(N, Matriz, 1, Diff) :-
	writeln('Insira o numero da coluna que deseja jogar: '),
	read(Move),
	%X - Linha e Y - Coluna
	Y = Move,                                      
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
	%Solicita a posicao em que o 1 quer jogar
    jogoSimplificado(N, Matriz, 1, Diff).                   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% JOGO - NORMAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

leitura_posicao(N, Matriz, Linha, Coluna):-
    repeat,
	writeln('Insira seu movimento ([X, Y].): '),
	read(Move),
	[Linha,Coluna] = Move,
	%Linha e coluna escolhida deve estar dentro o intervalo das dimensoes da matriz
    (Linha>0, Linha=<N), (Coluna>0, Coluna=<N+1),
	%Posicao correspondente a linha e coluna escolhida deve estar vazia   
    get_posicao(Matriz, Linha, Coluna, Elemento), Elemento=0, !.    

%Execucao do jogo
/* jogo loop */
jogo(Matriz, _, _) :-
	tab_gameover(Matriz),
	print_tab(Matriz),
	board_score(Matriz, S),
	writeln(S),
	!.

jogo(N, Matriz, 1, Diff) :-
	%X - Linha e Y - Coluna
	leitura_posicao(N, Matriz,X,Y),                              
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
	%Solicita a posicao em que o 1 quer jogar
    jogo(N, Matriz, 1, Diff).                   


%%%%%%%%%%%%%%%%%%%% VERIFICA FIM DE JOGO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Testa se o jogo deve continuar ou nao 
testa_fim_de_jogo(N, Matriz):-
	%Verifica fim de jogo sempre retorna true se o jogo deve continuar. Caso retorne false, cai pra linha de baixo
    not(verifica_fim_de_jogo(N, Matriz));  
	%Imprime o estado final do jogo e quem ganhou, alem de parar o jogo
    mostra_ganhador(N, Matriz), !, halt.    

%Imprime o estado final do jogo e quem ganhou
mostra_ganhador(N, Matriz):-
	%Descobre quem e o ganhador
    verifica_ganhador(N, Matriz, JogadorGanhador),                  
	%Imprime o estado final do jogo
    visualiza_estado(N, Matriz),     
	%Imprime quem ganhou o jogo
    mostra_jogador(JogadorGanhador).    

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
	%Pega a linha em que se esta realizando a jogada          
    get_linha(1, X, Matriz, R),    
	%Atualiza a lista correspondente a aquela linha
    set_posicao(R, Y, Jogador, NovaLinha),             
	%Atualiza a lista de listas - Coloca a linha atualizada
    set_posicao(Matriz, X, NovaLinha, NovaMatriz), !.   

set_coluna(Matriz, X, Y, Jogador, NovaMatriz) :-
	%Pega a linha em que se esta realizando a jogada          
	get_linha(1, X, Matriz, R),    
	%Atualiza a lista correspondente a aquela linha
    set_posicao(R, Y, Jogador, NovaLinha),             
	%Atualiza a lista de listas - Coloca a linha atualizada
    set_posicao(Matriz, X, NovaLinha, NovaMatriz), !.   

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
	%Testa se existe alguma linha toda preenchida por 1 ou 2
    verifica_fim_de_jogo_pela_linha(N, Matriz, JogadorGanhador), !;  
	%Testa se existe alguma coluna toda preenchida por 1 ou 2               
    verifica_fim_de_jogo_pela_coluna(N, Matriz, JogadorGanhador), !;                
	%Testa se a diagonal principal esta toda preenchida por 1 ou 2
    verifica_fim_de_jogo_pela_diagonal_principal(N, Matriz, JogadorGanhador), !;    
	%Testa se a diagonal secundaria esta toda preenchida por 1 ou 2
    verifica_fim_de_jogo_pela_diagonal_secundaria(N, Matriz, JogadorGanhador), !;   
    %Testa se a matriz esta toda preenchida - Nao existe nenhum valor 0 (Lugar vazio)
	verifica_fim_de_jogo_deu_velha(N, Matriz, JogadorGanhador), !.    

%Verifica se um elemento e um membro de uma lista
membro(X,[X|_]):-!.
membro(X,[_|T]):-membro(X,T).

%Verifica se a linha tem n simbolos consecutivos iguais 
n_consecutivos(_, [], 0).
n_consecutivos(X, [X | T], N) :- 
    n_consecutivos(X, T, N1), 
    N is N1 + 1.
n_consecutivos(X, [_ | T], 0) :- n_consecutivos(X, T, 0).

/*n_consecutivos_lista(_, [], 0).
n_consecutivos_lista(X, L, N) :-
    append(_, Suffix, L),
    append(Prefix, [X | _], Suffix),
    length(Prefix, M),
    n_consecutivos(X, Prefix, M1),
    N is max(M1, M),
    N >= N.*/ %Não vi necessidade desse predicado

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LINHA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Testa se tem alguma linha com todos valores 1 ou 2 (X ou O respectivamente)
%Testa se existe alguma linha em que em que há N elementos de 1 consecutivos, a partir da linha 1
verifica_fim_de_jogo_pela_linha(N, Matriz, 1):-testa_1_linha(N, 1, Matriz), !.  
%Testa se existe alguma linha em que há N elementos de 2 consecutivos, a partir da linha 1
verifica_fim_de_jogo_pela_linha(N, Matriz, 2):-testa_2_linha(N, 1, Matriz), !.  

%Testa se existe alguma linha em que todos elementos sao 1
testa_1_linha(N, Linha, Matriz):-
	%Pega a linha
    get_linha(1, Linha, Matriz, [X | R]),    
	%Testa se a linha tem n elementos 1 consecutivos, partindo do inicio ou excluindo a cabeça                   
    (n_consecutivos(1, [X | R],N); n_consecutivos(1,R,N)), !.  

%Recursao - Passa pra proxima linha
testa_1_linha(N, Linha, Matriz):-
    Linha=<N,
    Linha1 is Linha+1,
    testa_1_linha(N, Linha1, Matriz), !.

%Testa se existe alguma linha em que todos elementos sao 2
testa_2_linha(N, Linha, Matriz):-
	%Pega a linha
    get_linha(1, Linha, Matriz, [X | R]),  
	%Testa se a linha tem n elementos 2 consecutivos, partindo do inicio ou excluindo a cabeça                       
    (n_consecutivos(2, [X | R], N); n_consecutivos(2, R, N)), !. 

%Recursao - Passa pra proxima linha
testa_2_linha(N, Linha, Matriz):-
    Linha=<N,
    Linha2 is Linha+1,
    testa_2_linha(N, Linha2, Matriz), !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% COLUNA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Testa se tem alguma coluna com todos valores 1 ou 2 (X ou O respectivamente)
%Testa se existe alguma coluna em que há N elementos de 1 consecutivos
verifica_fim_de_jogo_pela_coluna(N, Matriz, 1):-testa_1_colunas(N, Matriz, 1, 1), !.    
%Testa se existe alguma coluna em que há N elementos de 2 consecutivos
verifica_fim_de_jogo_pela_coluna(N, Matriz, 2):-testa_2_colunas(N, Matriz, 1, 1), !.    

%Testa todas colunas buscando algum elemento diferente de 1
testa_1_colunas(N, Matriz, Linha, Coluna):-
    Coluna =< N+1,
    Coluna1 is Coluna+1,
	%Se nao encontrou, passa pra proxima coluna
    (not(testa_1_coluna(N, Matriz, Linha, Coluna)); testa_1_colunas(N, Matriz, Linha, Coluna1)), !. 

%Testa cada coluna buscando algum elemento diferente de 1
testa_1_coluna(_, Matriz, Linha, Coluna):-
	%Pega o elemento da matriz correspondente aquela posicao (linha, coluna)
    get_posicao(Matriz, Linha, Coluna, ElementoEncontrado),     
	%Testa se existe algum elemento diferente de 1
    ElementoEncontrado\=1, !.                     

%Recursao - Passa pra proxima linha
testa_1_coluna(N, Matriz, Linha, Coluna):-
    (Linha<N; Linha=N),
    Linha1 is Linha+1,
    testa_1_coluna(N, Matriz, Linha1, Coluna).

%Testa todas colunas buscando algum elemento diferente de 2
testa_2_colunas(N, Matriz, Linha, Coluna):-
    Coluna =< N+1,
    Coluna2 is Coluna+1,
	%Se nao encontrou, passa pra proxima coluna
    (not(testa_2_coluna(N, Matriz, Linha, Coluna)); testa_2_colunas(N, Matriz, Linha, Coluna2)), !. 

%Testa cada coluna buscando algum elemento diferente de 2
testa_2_coluna(_, Matriz, Linha, Coluna):-
	%Pega o elemento da matriz correspondente aquela posicao (linha, coluna)
    get_posicao(Matriz, Linha, Coluna, ElementoEncontrado),     
	%Testa se existe algum elemento diferente de 2
    ElementoEncontrado\=2, !.                     

%Recursao - Passa pra proxima linha
testa_2_coluna(N, Matriz, Linha, Coluna):-
    (Linha<N; Linha=N),
    Linha2 is Linha+1,
    testa_2_coluna(N, Matriz, Linha2, Coluna).

%%%%%%%%%%%%%%%%%%%%%%%% DIAGONAL PRINCIPAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Testa se tem alguma diagonal principal com todos valores 1 ou 2 (X ou O respectivamente)
%Testa se nao encontrou nenhum 0 ou 2 - So tem 1
verifica_fim_de_jogo_pela_diagonal_principal(N, Matriz, 1):-not(testa_1_diagonal_principal(N, Matriz, 1, 1)); not(testa_1_diagonal_principal(N, Matriz, 1, 2)), !. 
%Testa se nao encontrou nenhum 0 ou 1 - So tem 2
verifica_fim_de_jogo_pela_diagonal_principal(N, Matriz, 2):-not(testa_2_diagonal_principal(N, Matriz, 1, 1)); not(testa_2_diagonal_principal(N, Matriz, 1, 2)), !. 

testa_1_diagonal_principal(_, Matriz, Linha, Coluna):-
	%Pega o elemento da matriz correspondente aquela posicao (linha, coluna)
    get_posicao(Matriz, Linha, Coluna, ElementoEncontrado), 
	%Tenta encontrar algum 0 ou 2. Se nao achar, e porque so tem 1
    (ElementoEncontrado=0; ElementoEncontrado=2), !.   

%Recursao - Avanca uma linha e uma coluna, ja que se esta andando na diagonal principal
testa_1_diagonal_principal(N, Matriz, Linha, Coluna):-
    Linha=<N, Coluna=<N,
    Linha1 is Linha+1, Coluna1 is Coluna+1,
    testa_1_diagonal_principal(N, Matriz, Linha1, Coluna1).

testa_2_diagonal_principal(_, Matriz, Linha, Coluna):-
	%Pega o elemento da matriz correspondente aquela posicao (linha, coluna)
    get_posicao(Matriz, Linha, Coluna, ElementoEncontrado), 
	%Tenta encontrar algum 0 ou 1. Se nao achar, e porque so tem 2
    (ElementoEncontrado=0; ElementoEncontrado=1), !.  

%Recursao - Avanca uma linha e uma coluna, ja que se esta andando na diagonal principal
testa_2_diagonal_principal(N, Matriz, Linha, Coluna):-
    Linha=<N, Coluna=<N,
    Linha2 is Linha+1, Coluna2 is Coluna+1,
    testa_2_diagonal_principal(N, Matriz, Linha2, Coluna2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DIAGONAL SECUNDARIA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Testa se tem alguma diagonal secundaria com todos valores 1 ou 2 (X ou O respectivamente)
%Testa se nao encontrou nenhum 0 ou 2 - So tem 1
verifica_fim_de_jogo_pela_diagonal_secundaria(N, Matriz, 1):-not(testa_1_diagonal_secundaria(N, Matriz, 1, N)); not(testa_1_diagonal_secundaria(N, Matriz, 1, N+1)), !. 
%Testa se nao encontrou nenhum 0 ou 1 - So tem 2
verifica_fim_de_jogo_pela_diagonal_secundaria(N, Matriz, 2):-not(testa_2_diagonal_secundaria(N, Matriz, 1, N)); not(testa_2_diagonal_secundaria(N, Matriz, 1, N+1)), !. 

testa_1_diagonal_secundaria(_, Matriz, Linha, Coluna):-
	%Pega o elemento da matriz correspondente aquela posicao (linha, coluna)
    get_posicao(Matriz, Linha, Coluna, ElementoEncontrado), 
	%Tenta encontrar algum 0 ou 2. Se nao achar, e porque so tem 1
    (ElementoEncontrado=0; ElementoEncontrado=2), !.        

%Recursao - Avanca uma linha e volta uma coluna, ja que se esta andando na diagonal secundaria
testa_1_diagonal_secundaria(N, Matriz, Linha, Coluna):-
    Linha=<N, Coluna=<N+1,
    Linha1 is Linha+1, Coluna1 is Coluna-1,
    testa_1_diagonal_secundaria(N, Matriz, Linha1, Coluna1).

testa_2_diagonal_secundaria(_, Matriz, Linha, Coluna):-
	%Pega o elemento da matriz correspondente aquela posicao (linha, coluna)
    get_posicao(Matriz, Linha, Coluna, ElementoEncontrado), 
	%Tenta encontrar algum 0 ou 1. Se nao achar, e porque so tem 2
    (ElementoEncontrado=0; ElementoEncontrado=1), !.        
	
%Recursao - Avanca uma linha e volta uma coluna, ja que se esta andando na diagonal secundaria
testa_2_diagonal_secundaria(N, Matriz, Linha, Coluna):-
    Linha=<N, Coluna=<N+1,
    Linha2 is Linha+1, Coluna2 is Coluna-1,
    testa_2_diagonal_secundaria(N, Matriz, Linha2, Coluna2).

%%%%%%%%%%%%%%%%%%%%%%%%  VELHA  - EMPATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Testa se deu velha
%Testa se nao encontrou nenhum 0 - Se nao existe lugar vazio na matriz
verifica_fim_de_jogo_deu_velha(N, Matriz, 0):-not(testa_0_linha(N, 1, Matriz)), !.  

testa_0_linha(_, Linha, Matriz):-
	%Pega uma linha
    get_linha(1, Linha, Matriz, R), 
	%Tenta encontrar algum 0 na linha. Se nao achar, e porque so tem 1 ou 2
    membro(0, R), !.                

%Recursao - Avanca pra proxima linha
testa_0_linha(N, Linha, Matriz):-
    Linha=<N,
    Linha0 is Linha+1,
    testa_0_linha(N, Linha0, Matriz), !.


%%%%%%%%%%%%%%%%%%%%%% DECISÃO IA - USANDO MINMAX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


concat([], L, L).
concat([H | T], L2, [H | L]) :-
	concat(T, L2, L).

%transforma uma matriz em um vetor
matriz_vetor([], []) :-
	!.
	
matriz_vetor(A, [A]) :-
	atomic(A).

matriz_vetor([H | T], R) :-
	matriz_vetor(H, V),
	matriz_vetor(T, T2),
	concat(V, T2, R).
	
%conta a quantidade de ocorrências de um valor em um vetor
conta_vetor([], _, 0).

conta_vetor([E | T], E, Count) :-
	conta_vetor(T, E, NewCount),
	Count is NewCount + 1,
	!.
	
conta_vetor([H | T], E, Count) :-
	H \= E,
	conta_vetor(T, E, Count).
	
%retorna o tamanho de um vetor
tam_vetor([], 0).
tam_vetor([_ | T], S) :-
	tam_vetor(T, NS),
	S is NS + 1.

%verifica se dois vetores são iguais
vetor_igual([], []) :-
	!.

vetor_igual([H | VT], [H | WT]) :-
	vetor_igual(VT, WT).
	
%insere um valor em uma posição de um vetor
set_vetor([_ | T], 1, V, [V | T]) :-
	!.

set_vetor([H | T], X, V, [H | NL]) :-
	Y is X - 1,
	set_vetor(T, Y, V, NL).

%adiciona um elemento ao final de um vetor
vetor_append([], X, [X]) :-
	!.
	
vetor_append([H | T], X, [H | NT]) :-
	vetor_append(T, X, NT).

%obtém um elemento de um vetor
get_vetor([H | _], 1, H) :-
	!.
	
get_vetor([_ | T], I, V) :-
	J is I - 1,
	get_vetor(T, J, V).

%verifica se o vetor contém um valor	
vetor_contem([H | _], H).

vetor_contem([_ | T], H) :-
	vetor_contem(T, H).
	
%retorna o número de linhas e colunas da matriz
dim_matriz(M, X, Y) :-
	tam_vetor(M, X),
	X == 0,
	!,
	Y = 0.
	
dim_matriz(M, X, Y) :-
	tam_vetor(M, X),
	get_linha_matriz(M, 1, R),
	tam_vetor(R, Y).
	
%atribui uma linha na matriz
set_linha_matriz([_ | T], 1, R, [R | T]) :-
	!.
	
set_linha_matriz([H | T], I, R, [H | M]) :-
	J is I - 1,
	set_linha_matriz(T, J, R, M).
	
%retorna uma linha da matriz
get_linha_matriz([R | _], 1, R) :-
	!.
	
get_linha_matriz([_ | M], I, R) :-
	J is I - 1,
	get_linha_matriz(M, J, R).

%retorna uma coluna da matriz	
get_coluna_matriz([], _, []).
	
get_coluna_matriz([R | M], I, [C | X]) :-
	get_vetor(R, I, C),
	get_coluna_matriz(M, I, X).
	
matriz_diag(M, D) :-
	matriz_diag(M, D, 1).

matriz_diag([], [], _).

matriz_diag([R | M], [C | D], I) :-
		get_vetor(R, I, C),
		J is I + 1,
		matriz_diag(M, D, J).
		
matriz_diag_dir(M, D) :-
	dim_matriz(M, Rows, _),
	matriz_diag_dir(M, D, Rows).
	
matriz_diag_dir([], [], _).

matriz_diag_dir([R | M], [C | D], I) :-
	get_vetor(R, I, C),
	J is I - 1,
	matriz_diag_dir(M, D, J).

matriz_transposta(M, M2) :-
	dim_matriz(M, _, Columns),
	matriz_transposta(M, M2, 1, Columns).
	
matriz_transposta([], [], _, _).

matriz_transposta(_, [], ColumnIndex, MaxIndex) :-
	ColumnIndex > MaxIndex,
	!.

matriz_transposta(M, [C | X], ColumnIndex, MaxIndex) :-
	ColumnIndex =< MaxIndex,
	!,
	NextIndex is ColumnIndex + 1,
	get_coluna_matriz(M, ColumnIndex, C),
	matriz_transposta(M, X, NextIndex, MaxIndex).

%atribui um valor a uma posição da matriz
set_matriz(M, X, Y, V, NM) :-
	get_linha_matriz(M, X, R),
	set_vetor(R, Y, V, NR),
	set_linha_matriz(M, X, NR, NM).
	

%vetores de vitória
vitoria(2, [2, 2, 2]).
vitoria(1, [1, 1, 1]). 

%símbolos do jogo
simbolo(0, '   ').
simbolo(2, ' O ').
simbolo(1, ' X ').

%printa o tabuleiro
print_tab([]) :-
	writeln(' ').

print_tab([R | M]) :-
	print_tab_linha(R),
	writeln(' '),
	print_tab(M).
	
%printa uma linha do tabuleiro
print_tab_linha([]).
	
print_tab_linha([C | R]) :-
	simbolo(C, X),
	write(X),
	write(' '),
	print_tab_linha(R).

tab_prox_jogada(2, 1).
tab_prox_jogada(1, 2).

tab_faz_mov(B, X, Y, Value, NB) :-
	set_matriz(B, X, Y, Value, NB).
 
%game over
tab_gameover(B) :-
	matriz_vetor(B, X),
	not(vetor_contem(X, 0)),
	!.

tab_gameover(B) :- 
	matriz_diag(B, D),
	tab_gameover_cond(D),
	!.
	
tab_gameover(B) :-
	matriz_diag_dir(B, D2),
	tab_gameover_cond(D2),
	!.	
	
tab_gameover(B) :-
	tab_gameover_linhas(B),
	!.

tab_gameover(B) :-
	matriz_transposta(B, M),
	tab_gameover_linhas(M),
	!.
	
tab_gameover_linhas([R | _]) :-
	tab_gameover_cond(R).
	
tab_gameover_linhas([_ | B]) :-
	tab_gameover_linhas(B).
	
tab_gameover_cond(R) :-
	vitoria(1, V),
	vetor_igual(R, V).
	
tab_gameover_cond(R) :-
	vitoria(2, V),
	vetor_igual(R, V).

/* returns the score (heuristic) of the board */
board_score(B, Score) :-
	matriz_diag(B, D),
	matriz_diag_dir(B, D2),
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
	matriz_transposta(B, M),
	board_rows_score(M, Score).

board_row_score(R, Score) :-
	conta_vetor(R, 1, 0),
	conta_vetor(R, 2, ScoreAI),
	ScoreAI > 0,
	Exponent is ScoreAI - 1,
	pow(10, Exponent, Score),
	!.

board_row_score(R, Score) :-
	conta_vetor(R, 2, 0),
	conta_vetor(R, 1, ScoreHuman),
	ScoreHuman > 0,
	Exponent is ScoreHuman - 1,
	pow(10, Exponent, S),
	Score is -S,
	!.

board_row_score(_, 0).

/* returns a list of possible moves */
board_free_cells(B, C) :-
	dim_matriz(B, Rows, Columns),
	board_free_cells(B, Rows, Columns, C).
	
board_free_cells(_, 0, _, []) :-
	!.

board_free_cells(Board, RowIndex, 0, Cells) :-
	dim_matriz(Board, _, Columns),
	NRowIndex is RowIndex - 1,
	board_free_cells(Board, NRowIndex, Columns, Cells).

board_free_cells(Board, RowIndex, ColumnIndex, [[RowIndex, ColumnIndex] | Rest]) :-
	get_linha_matriz(Board, RowIndex, Row),
	get_vetor(Row, ColumnIndex, 0),
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
	tab_gameover(B),
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
	tab_faz_mov(B, X, Y, Turn, NB),
	tab_prox_jogada(Turn, NextTurn),
	generate_ai_decision(NextTurn, NB, D, [_, _, Decision]),
	generate_ai_decision_recursion(Turn, B, Depth, T, Scores).