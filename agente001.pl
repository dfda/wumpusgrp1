% Some simple test agents.
%
% To define an agent within the navigate.pl scenario, define:
%   init_agent
%   restart_agent
%   run_agent
%
% Currently set up to solve the wumpus world in Figure 6.2 of Russell and
% Norvig.  You can enforce generation of this world by changing the
% initialize(random,Percept) to initialize(fig62,Percept) in the
% navigate(Actions,Score,Time) procedure in file navigate.pl and then run
% navigate(Actions,Score,Time).

% Lista de Percepcao: [Stench,Breeze,Glitter,Bump,Scream]
% Traducao: [Fedor,Vento,Brilho,Trombada,Grito]
% Acoes possiveis:
% goforward - andar
% turnright - girar sentido horario
% turnleft - girar sentido anti-horario
% grab - pegar o ouro
% climb - sair da caverna
% shoot - atirar a flecha

% Copie wumpus1.pl e agenteXX.pl onde XX eh o numero do seu agente (do grupo)
% para a pasta rascunhos e depois de pronto para trabalhos
% Todos do grupo devem copiar para sua pasta trabalhos, 
% com o mesmo NUMERO, o arquivo identico.

% Para rodar o exemplo, inicie o prolog com:
% swipl -s agente007.pl
% e faca a consulta (query) na forma:
% ?- start.

:- load_files([wumpus3]).
:- dynamic ([agent_flecha/1, wumpus/1, ouro/1, minhacasa/1, orientacao/1, casas_seguras/1, casas_visitadas/1, casa_anterior/1, casa_da_frente/1]). %fatos dinamicos

wumpusworld(pit3, 4).

init_agent :-                       % se nao tiver nada para fazer aqui, simplesmente termine com um ponto (.)
    writeln('Agente iniciando...'), % apague esse writeln e coloque aqui as acoes para iniciar o agente
    retractall(minhacasa(_)),
    assert(minhacasa([1,1])),       % casa inicial
    retractall(orientacao(_)),
    assert(orientacao(0)),          % orientecao inicial
    retractall(agent_flecha(_)),
    assert(agent_flecha(1)),        % numero inicial de flechas 
    retractall(wumpus(_)),
    assert(wumpus(alive)),          % estado inicial do wumpus
    retractall(ouro(_)), 
    assert(ouro(0)),                % quantodade inicial de ouro
    retractall(casas_seguras(_)),
    assert(casas_seguras([[1,1]])), % lista inicial de casas seguras
    retractall(casas_visitadas(_)),
    assert(casas_visitadas([[1,1]])), % lista inicial de casas visitadas
    retractall(casa_anterior(_)),
    assert(casa_anterior([1,1])),
    retractall(casa_da_frente([_,_])),
    assert(casa_da_frente([2,1])).


restart_agent :- 
    init_agent.

run_agent(Percepcao, Acao) :-
    nl,
    write('Percebi: '), 
    writeln(Percepcao),
    minhacasa(Posicao),             % Chamada da funcao minhacasa para saber a posicao atual
    write('Minha posicao: '),
    writeln(Posicao),
    adjacentes(Posicao, L),         % Chamada da funcao adjacente para obter uma lista de casas adjacentes
    write('Casas adjacentes: '),
    writeln(L),
    orientacao(Sentido),            % Chamada da funcao orientacao para saber a orientacao atual do agente
    write('Sentido do agente: '),
    writeln(Sentido),
    faz_frente(Posicao, Sentido, Frente), % Chamada da funcao frente para saber a casa a frente do agente
    casa_da_frente(Frente),
    write('Casa frente: '),
    writeln(Frente),
    %faz_casa_anterior(Posicao),
    casa_anterior(Ca),
    write('Casa anterior: '),
    faz_casas_visitadas(Posicao),
    casa_anterior(Ca),
    write('Casa anterior: '),
    writeln(Ca),
    faz_casas_visitadas(Posicao),
    casas_visitadas(Cv),
    write('Casas visitadas: '),
    writeln(Cv),
    faz_casas_seguras(Posicao, L, Percepcao, Csa),
    atualiza_casas_seguras(Csa),
    casas_seguras(Cs),   % Chamada da funcao casa segura, dependendo da percepcao do agente
    write('Casas seguras: '),
    writeln(Cs),
    agent_flecha(Flecha),           % Chamada para recolher o valor da variavel Flecha
    write('Numero de flechas: '), 
    writeln(Flecha),
    ouro(Q),                        % Chamada para recolher quantidade do ouro %
    write('Quantidade de ouro: '),
    writeln(Q),
    estou_sentindo_uma_treta(Percepcao, Acao),
    faz_casa_anterior(Ca).
    % caminho_seguro(CS),
    %write('Caminho seguro: '),
    % writeln(CS).
    
% Fatos (acoes que vao ser executadas)

faz_casa_anterior(Ca) :-
    minhacasa([X,Y]),
    casa_anterior([L,M]),
    Y==M,
    X==L,
    retractall(casa_anterior(_)),
    assert(casa_anterior(Ca)).

faz_casa_anterior(Ca) :-
    true.

estou_sentindo_uma_treta([_,_,_,_,_], climb):- %Agente sai da caverna caso possua ouro e esteja na casa [1,1]
    minhacasa([1,1]),
    ouro(1).

estou_sentindo_uma_treta([_,_,_,_,_], climb):- %Agente sai da caverna caso esteja na casa [1,1] e tenha matado o wumpus
    minhacasa([1,1]),
    wumpus(dead).

estou_sentindo_uma_treta([_,_,_,_,yes], _):- %Wumpus morto apos agente ouvir o grito%
    retractall(wumpus(_)), 
    assert(wumpus(dead)),
    fail.

estou_sentindo_uma_treta([_,_,no,yes,no], turnleft):-    %fazer agente virar para esquerda ao sentir trombada
    novosentidoleft.

estou_sentindo_uma_treta([yes,_,_,_,_], shoot) :-  %agente atira caso tenha flecha e wumpus esteja vivo%
    agent_flecha(X), 
    X==1, 
    wumpus(alive), 
    tiro,
    write('Wumpus morto !!!'), nl.

estou_sentindo_uma_treta([_,_,no,no,_], goforward):- %agente segue em frente caso nao haja ouro e nao sinta trombada%
    orientacao(Ori),
    minhacasa([X,Y]),
    retractall(casa_anterior(_)),
    assert(casa_anterior([X,Y])),
    novaposicao(Ori).

estou_sentindo_uma_treta([no,no,no,no,no], goforward):- %agente segue em frente caso todas as percepcoes seja no.
     orientacao(Ori),
     minhacasa([X]),
     retractall(casa_anterior(_)),
     assert(casa_anterior([X])),
     novaposicao(Ori).

%estou_sentindo_uma_treta([_,yes,_,_,_], turnleft):-

estou_sentindo_uma_treta([_,_,yes,_,_],  grab):- %agente coleta ouro ao perceber seu brilho%
    retractall(ouro(_)),
    assert(ouro(1)),
    write('Estou com ouro !!!'),nl.

% Funcoes
tiro :-  %agente com flecha e capaz de atirar no wumpus e flecha e decrementada%
    agent_flecha(X),
    X>0,
    X1 is X-1,
    retractall(agent_flecha(_)),
    assert(agent_flecha(X1)).

faz_casas_seguras(Posicao, L, [no,no,_,_,_], Csa):- %casas que sao seguras, com base em casas adjacentes e minha posicao atual%
    append([Posicao], L, Csb),
    list_to_set(Csb, Csa).

faz_casas_seguras(Posicao, _, [_,_,_,_,_], Csa):- % Caso o agente sinta algo, a lista de casas_seguras adiciona a casa da posicao atual do agente
    Csa=[Posicao].

atualiza_casas_seguras(Csa):- % Sempre recebe a variavel Csa para adicionar na lista Cs criando uma nova lista, atualizando a lista de casas seguras
    casas_seguras(Cs),
    append(Csa, Cs, NovaLista1),
    list_to_set(NovaLista1, NovaLista), %list_to_set para retirar casas repetidas da lista atualizada
    retractall(casas_seguras(_)),
    assert(casas_seguras(NovaLista)).

faz_casas_visitadas(Posicao) :-  %regra para salvar casas visitadas%
    casas_visitadas(Cv),
    append([Posicao], Cv, NovaLista1),
    list_to_set(NovaLista1, NovaLista),
    retractall(casas_visitadas(_)),
    assert(casas_visitadas(NovaLista)).

%caminho_seguro:- 
%   minhacasa([X,Y]),
%   casas_seguras(Cs),
%   ((not(member([X,Y], Cs)),
%   append(Cs, [X,Y], NL),
%   retractall(casas_seguras(_)),
%   assert(casas_seguras(NL))|(true)).

frente([X, Y], Ori, L):- % caso a orientacao do agente seja 0, a casa da frente sera com o 1o elemento da lista mais 1
    Ori==0,
    X1 is X + 1,
    L=[X1, Y].

frente([X, Y], Ori, L):- % caso a orientacao do agente seja 90, a casa da frente sera com o 2o elemento da lista mais 1
    Ori==90,
    Y1 is Y + 1,
    L=[X, Y1].

frente([X, Y], Ori, L):- % caso a orientacao do agente seja 180, a casa da frente sera com o 1o elemento da lista menos 1
    Ori==180,
    X1 is X - 1,
    L=[X1, Y].

frente([X, Y], Ori, L):- % caso a orientacao do agente seja 270, a casa da frente sera com o 2o elemento da lista mais 1
    Ori==270,
    Y1 is Y - 1,
    L=[X, Y1].

novosentidoleft:- %muda a memoria do sentido atual caso aconteca um turnleft
    orientacao(S),
    O is (S+90) mod 360,
    retractall(orientacao(_)),
    assert(orientacao(O)).
novosentidoright:- %muda a memoria do sentido atual caso aconteca um turnright
    orientacao(S),
    O is (S-90) mod 360,
    retractall(orientacao(_)),
    assert(orientacao(O)).

novaposicao(0):- 
    minhacasa([X,Y]),
    X<4,
    X1 is X+1,   
    retractall(minhacasa([_|_])),
    assert(minhacasa([X1,Y])).

novaposicao(0):- 
    minhacasa([X,Y]),
    X==4,
    X1 is X,  
    retractall(minhacasa([_,_])),
    assert(minhacasa([X1,Y])).

novaposicao(90):-
    minhacasa([X,Y]),
    Y<4,
    Y1 is Y+1, 
    retractall(minhacasa([_,_])),
    assert(minhacasa([X,Y1])).

novaposicao(90):-
    minhacasa([X,Y]),
    Y==4,
    Y1 is Y, 
    retractall(minhacasa([_,_])),
    assert(minhacasa([X,Y1])).

novaposicao(180):-
    minhacasa([X,Y]),
    X>1,
    X1 is X-1,
    retractall(minhacasa([_,_])),
    assert(minhacasa([X1,Y])).

novaposicao(180):-
    minhacasa([X,Y]),
    X==1,
    X1 is X,
    retractall(minhacasa([_,_])),
    assert(minhacasa([X1,Y])).

novaposicao(270):-
    minhacasa([X,Y]),
    Y>1,
    Y1 is Y-1,
    retractall(minhacasa([_,_])),
    assert(minhacasa([X,Y1])).

novaposicao(270):-
    minhacasa([X,Y]), 
    Y==1,
    Y1 is Y,
    retractall(minhacasa([_,_])),
    assert(minhacasa([X,Y1])).

% Casas adjacentes
% A regra chamara outras regrar para somar e diminuir cara coordenada
adjacentes([X, Y], L):-
    X\==1,
    X\==4,
    Y\==1,
    Y\==4,
    cima([X, Y], L1),
    baixo([X, Y], L2),
    esquerda([X, Y], L3),
    direita([X, Y], L4),
    L=[L1, L2, L3, L4].

adjacentes([X, Y], L):-
    X==1,
    Y==1,
    cima([X, Y], L1),
    direita([X, Y], L4),
    L=[L1, L4].

adjacentes([X, Y], L):-
    X==4,
    Y==1,
    cima([X, Y], L1),
    esquerda([X, Y], L3),
    L=[L1, L3].

adjacentes([X, Y], L):-
    X==1,
    Y==4,
    direita([X, Y], L4),
    baixo([X, Y], L2),
    L=[L2, L4].

adjacentes([X, Y], L):-
    X==4,
    Y==4,
    baixo([X, Y], L2),
    esquerda([X, Y], L3),
    L=[L2, L3].

adjacentes([X, Y], L):-
    X\==1,
    X\==4,
    Y==1,
    esquerda([X, Y], L3),
    direita([X, Y], L4),
    cima([X, Y], L1),
    L=[L1, L3, L4].

adjacentes([X, Y], L):-
    X\==1,
    X\==4,
    Y==4,
    esquerda([X, Y], L3),
    direita([X, Y], L4),
    baixo([X, Y], L2),
    L=[L2, L3, L4].

adjacentes([X, Y], L):-
    Y\==1,
    Y\==4,
    X==1,
    cima([X, Y], L1),
    direita([X, Y], L4),
    baixo([X, Y], L2),
    L=[L1, L2, L4].

adjacentes([X, Y], L):-
    Y\==1,
    Y\==4,
    X==4,
    cima([X,Y], L1),
    esquerda([X, Y], L3),
    baixo([X, Y], L2),
    L=[L1, L2, L3].

% Funcoes para calcular as coordenas das casas adjacentes
cima([X, Y], L1):-
    Y1 is Y + 1,
    L1=[X, Y1].

baixo([X, Y], L2):-
    Y2 is Y - 1,
    L2=[X, Y2].

esquerda([X, Y], L3):-
    X2 is X - 1,
    L3=[X2, Y].

direita([X, Y], L4):-
    X1 is X + 1,
    L4=[X1, Y].

