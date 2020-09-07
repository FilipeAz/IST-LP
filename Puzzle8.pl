% Grupo 110:
% Filipe Azevedo n82468;
% Bruno Lopes n82457.

%__________________________________________________________________________________________________________________________________________________
% Predicados gerais:

% is_0\1 escreve um espaco em branco e vez de escrever o '0' da configuracao.
is_0(A):- A == 0,write(' ');A < 10,write(A).



% escreve_linha\2 que escreve no ecra uma linha da configuracao. 
% predicado auxiliar do transformacao_desejada.
escreve_linha([],_).
escreve_linha([A,B,C|R],Resto):-write(' '),is_0(A),write('  '),is_0(B),write('  '),is_0(C),Resto=R.



% transformacao_desejada\2 escreve no ecra a configuracao inicial e a final.
transformacao_desejada(C1,C2):- write('Transformacao desejada:'),nl,
								escreve_linha(C1,C1_1),write('     '),escreve_linha(C2,C2_1),nl,
								escreve_linha(C1_1,C1_2),write('  -> '),escreve_linha(C2_1,C2_2),nl,
								escreve_linha(C1_2,_),write('     '),escreve_linha(C2_2,_),nl.

								
								
% escreve_puzzle\2 escreve o puzzle no decorrer do programa.
escreve_puzzle(C):-escreve_puzzle(C,0).
escreve_puzzle([],_).
escreve_puzzle([P|R],I):- I\=3,I\=7,I\=11,write(' '),is_0(P),write(' '),I1 is I+1,
						  escreve_puzzle(R,I1);(I==3;I==7;I==11),nl,I1 is I+1,escreve_puzzle([P|R],I1).

						  
						  
% troca\4 troca de posicao de dois elementos de uma lista.
% recebe a configuracao inicial, os dois elementos a trocar e a configuracao final.
troca([],_,_,[]).
troca([P|R],E1,E2,[P1|R1]):- P==E1,P1 is E2,troca(R,E1,E2,R1),!;
							 P==E2,P1 is E1,troca(R,E1,E2,R1),!;
							 P1 is P,troca(R,E1,E2,R1).

							 
							 
% indice\3 indica a indice (a comecar em 1) de um elemento numa lista.
% recebe o indice, a lista e um elemento.
indice(1,[Element|_],Element).
indice(Index,[_|R],Element):- indice(Index1,R,Element),Index is Index1+1.



% mov_legal\4 e um literal que vai ser fundamental no rpograma uma vez que vai ser usado em todos os tipos de resolucao.
% Por exemplo, o literal mov_legal(C1, M, P, C2) afirma que a configuração C2 é obtida da configuração C1, fazendo o movimento M, com a peça P.
mov_legal(C1,c,P,C2):- indice(X,C1,0),X1 is X+3,X1>0,X1<10,indice(X1,C1,P),troca(C1,0,P,C2).
mov_legal(C1,b,P,C2):- indice(X,C1,0),X1 is X-3,X1>0,X1<10,indice(X1,C1,P),troca(C1,0,P,C2).
mov_legal(C1,e,P,C2):- indice(X,C1,0),X1 is X+1,X1>0,X1<10,X mod 3 =\= 0,indice(X1,C1,P),troca(C1,0,P,C2).
mov_legal(C1,d,P,C2):- indice(X,C1,0),X1 is X-1,X1>0,X1<10,X mod 3 =\= 1,indice(X1,C1,P),troca(C1,0,P,C2).



% existe_na_lista\2 recebe uma lista e um elemento e apenas sucede se o elemento dado existe na lista.
existe_na_lista([],_):- fail.
existe_na_lista([L1|_],L1):-!.
existe_na_lista([_|R],L2):-existe_na_lista(R,L2).



% adiciona\3 junta duas listas.
adiciona([],L,L).
adiciona([P|R],L,[P|L2]):-adiciona(R,L,L2).



% escreve_solucao/1 escreve as jogadas necessarias para chegar a configuracao final.
% escreve_solucao(M) em que M e uma lista de movimentos e um movimento e um par (Mov, Peca).
escreve_solucao([]).
escreve_solucao([(M, P) | []]) :- write('mova a peca '), 
                                  write(P), 
                                  traduz(M, Mp), 
                                  write(Mp),
                                  write('.'),
                                  nl.
escreve_solucao([(M, P) | R]) :- write('mova a peca '), 
                                 write(P), 
                                 traduz(M, Mp), 
                                 write(Mp),
                                 nl, 
                                 escreve_solucao(R).

								 

% traduz/2 e um predicado auxiliar de escreve_solucao/1
traduz(c, ' para cima').
traduz(b, ' para baixo').
traduz(e, ' para a esquerda').
traduz(d, ' para a direita').

%__________________________________________________________________________________________________________________________________________________
%Solucao Manual



% movimento\2 e um predicado que faz as alteracoes na configuracao conforme as regras do jogo.
movimento([P|R],Nova_lista):- write('Qual o seu movimento?'),nl,read(Direcao),mov_legal([P|R],Direcao,_,X),
							  (Nova_lista==X,escreve_puzzle(X),nl,nl,write('Parabens!');
							  nl,escreve_puzzle(X),nl,nl,movimento(X,Nova_lista));
							  write('Movimento ilegal'),nl,movimento([P|R],Nova_lista).

							  
							  
% resolve_manual\2 recebe uma configuracao inicial e uma final e vai pedindo ao utilizador que lhe forneca direcoes, mudando a configuracao
% de acordo com as direcoes dadas ate chegar a solucao.
resolve_manual(C1,C2):-transformacao_desejada(C1,C2),transformacao_possivel(C1,C2),!,movimento(C1,C2),!.

%__________________________________________________________________________________________________________________________________________________
%Solucao Cega

% procura\2 gera movimentos na configuracao e verifica se essa nova configuracao ja nao foi calculada guardando o par (movimento,peca)
% nesse caso e gerando outro movimento em caso contrario.
procura(C1,C2):-procura(C1,C2,[C1],[]).
procura(C,C,_,L_jogadas):-escreve_solucao(L_jogadas).
procura(C1,C2,L,L_jogadas):-mov_legal(C1,D,P,Prox_tab),not(existe_na_lista(L,Prox_tab)),
							adiciona(L,[Prox_tab],L1),adiciona(L_jogadas,[(D,P)],Nova_L_jogadas),
							procura(Prox_tab,C2,L1,Nova_L_jogadas).       

							
							
% resolve_cego\2 recebe uma configuracao inicial e uma final e vai gerando movimentos de acordo com a ordem do literal mov_legal, mudando a configuracao
% se essa ja nao tiver sido calculada anteriormente.
resolve_cego(C1,C2):- transformacao_desejada(C1,C2),transformacao_possivel(C1,C2),procura(C1,C2),!.

%__________________________________________________________________________________________________________________________________________________
%Solucao Informada

% distancia_de_Hamming\3 calcula a distancia de Hamming entre duas listas.
distancia_de_Hamming([],[],0).
distancia_de_Hamming([P1|R1],[P2|R2],H):- (P1==0;P1==P2),distancia_de_Hamming(R1,R2,H),!;
										  (P1\=P2,distancia_de_Hamming(R1,R2,H_novo),H is H_novo+1).

										  
										  
% menor\3 unifica com o menor F (F=numero de transformacoes realizadas desde o estado inicial + distancia de Hamming) e com a configuracao 
% que lhe esta associada, nao interessando a jogada feita para obter essa configuracao.
menor([[T,P,_]|R],Tab,M):-menor(R,Tab,M,[T,P,_]).
menor([],T,M,[T,M,_]).
menor([[T,P,_]|R],T_res,Res,[_,M,_]):-P<M,!,menor(R,T_res,Res,[T,P,_]).
menor([[_,P,_]|R],T_res,Res,[Prev_T,M,_]):-P>=M,menor(R,T_res,Res,[Prev_T,M,_]).



% remove\3 remove um elemento da primeira lista, unificando a primeira lista sem esse elemento com a segunda lista.
remove([],_,[]).
remove([P|R],P,R):-!.
remove([P|R],E,[P|R1]):-remove(R,E,R1).



% inverte\2 inverte a ordem dos elementos numa lista.
inverte(L,I):-inverte(L,[],I).
inverte([],I,I).
inverte([P|R],Ac,I):-inverte(R,[P|Ac],I).



% procura_informada\6 L unifica com uma lista contendo varias listas em que cada uma contem uma transformacao possivel da lista C1 que ainda nao exista
% na lista dos abertos nem na lista dos fechados, o seu respetivo valor de F e o seu par (movimento,peca).
procura_informada(C1,C2,L_Abertos,L_Fechados,Cont,L):-findall([Novo_C,F,(D,P)],(mov_legal(C1,D,P,Novo_C),transformacao_possivel(Novo_C,C2),
													  not(existe_na_lista(L_Fechados,Novo_C)),not(existe_na_lista(L_Abertos,(Novo_C,_,_))),
													  distancia_de_Hamming(Novo_C,C2,H),F is H+Cont),L).
									

									
% informada\2 e um literal que recebe uma configuracao e a configuracao final.
% informada\6 recebe duas configuracoes, uma lista de Abertos que contem varias listas contendo todas as configuracoes ja geradas e que ainda
% nao foram expandidas, o respetivo valor de F e o seu par (movimento,peca), uma lista de Fechados que contem todas as configuracoes ja expandidas,
% uma lista de Jogadas que contem todos os pares (movimento,peca) obtidos de cada configuracao e um contador, essencial para o calculo de F.
% Comeca por retirar da lista de Abertos a configuracao a expandir e a coloca-la na lista de Fechados. Obtem todas as configuracoes possiveis
% do literal procura_informada\6 e adiciona essa lista a lista de Abertos. De seguida inverte a lista de Abertos de e obtem a configuracao que 
% possui o menor valor de F (e necessario inverter de forma a poder obter a configuracao com menor valor de F mais recente), e adiciona-se
% o seu par (movimento,jogada) a lista de Jogadas. Continua-se no ciclo ate se encontrar a solucao. Quando isto acontece, imprime-se as jogadas feitas.
informada(C1,C2):-distancia_de_Hamming(C1,C2,H),informada(C1,C2,[[C1,H,_]],[],[],1).
informada(C,C,_,_,L_jogadas,_):-escreve_solucao(L_jogadas).
informada(C1,C2,L_Abertos,L_Fechados,L_jogadas,Cont):-remove(L_Abertos,[C1,_,_],L_Abertos_aux),
													  adiciona(L_Fechados,[C1],Novo_L_Fechados),
													  procura_informada(C1,C2,L_Abertos_aux,Novo_L_Fechados,Cont,L),
													  adiciona(L_Abertos_aux,L,Novo_L_Abertos),
													  inverte(Novo_L_Abertos,L_Abertos_inversa),menor(L_Abertos_inversa,Prox_Tab,_),
													  indice(_,Novo_L_Abertos,[Prox_Tab,_,J]),
													  adiciona(L_jogadas,[J],Nova_L_jogadas),Cont_novo is Cont+1,
													  informada(Prox_Tab,C2,Novo_L_Abertos,Novo_L_Fechados,Nova_L_jogadas,Cont_novo).

													  
													  
													
% resolve_info_h\2 recebe uma configuracao inicial e uma final e atraves do literal informada\2 descobre a solucao se for possivel.
resolve_info_h(C1,C2):-transformacao_desejada(C1,C2),!,transformacao_possivel(C1,C2),informada(C1,C2),!.

%____________________________________________________________________________________________________________________________________________________________
%Credito adicional

% Para saber se uma transformacao e possivel ou nao temos de calcular o numero de inversoes de numeros que existem entre a configuracao inicial e
% a configuracao final. Uma inversao corresponde a um numero X ter menor indice na primeira configuracao do que um outro Y 
% e na ultima configuracao Y tem um menor indice que X. S o numero de inversoes for impar, nao ha solucao. Caso contrario existe solucao.
% Por exemplo: [1,2,3,4,5,6,7,8,0] e [1,2,3,4,5,6,8,7,0]. Nao se consegue chegar a segunda a partir da primeira porque 
% apenas ha uma inversao, o 7 e o 8 (I1(8)=8 e I1(7)= 7 mas I2(8)=7 e I2(7)=8).
% Outro exemplo: [1,2,3,4,5,6,7,8,0] e [2,1,3,4,6,5,8,7,0]. Nao e possivel porque ha 3 inversoes (1-2, 5-6, 7-8).
transformacao_possivel(C1,C2):- transformacao_possivel([1,2,3,4,5,6,7,8],C1,C2,I,0), I mod 2 =:= 0.
transformacao_possivel([],_,_,Res,Res):-!.
transformacao_possivel([X|R],C1,C2,Res,Total):- verifica(X,R,C1,C2,I,0), Total1 is Total + I, 
												transformacao_possivel(R,C1,C2,Res,Total1).


												
verifica(_,[],_,_,I,I):-!.
verifica(X,[Y|R],C1,C2,I,Ac):- indice(A1,C1,X),indice(A2,C2,X),indice(B1,C1,Y),indice(B2,C2,Y),
							   (A1<A2,B1>B2 ; A1>A2,B1<B2),!,
							   Ac1 is Ac +1, verifica(X,R,C1,C2,I,Ac1);verifica(X,R,C1,C2,I,Ac).


















