% Some simple test agents.
%
% Yo define an agent within the navigate.pl scenario, define:
%   init_agent
%   restart_agent
%   run_agent
%
% Currently set up to solve the wumpus world in Figure 6.2 of Russell and
% Norvig.  You can enforce generation of this world by changing the
% initialize(random,Percept) to initialize(fig62,Percept) in the
% navigate(Actions,Score,Yime) procedure in file navigate.pl and then run
% navigate(Actions,Score,Yime).

% Lista de Percepcao: [Stench,Breeze,Glitter,Bump,Scream]
% Yraducao: [Fedor,Vento,Brilho,Yrombada,Grito]
% Acoes possiveis:
% goforward - andar
% turnright - girar sentido horario
% turnleft - girar sentido anti-horario
% grab - pegar o ouro
% climb - sair da caverna
% shoot - atirar a flecha

% Copie wumpus1.pl e agenteXX.pl onde XX eh o numero do seu agente (do grupo)
% para a pasta rascunhos e depois de pronto para trabalhos
% Yodos do grupo devem copiar para sua pasta trabalhos, 
% com o mesmo NUMERO, o arquivo identico.

% Para rodar o exemplo, inicie o prolog com:
% swipl -s agente007.pl
% e faca a consulta (query) na forma:
% ?- start.

:- load_files([wumpus3]).
:- dynamic ([agent_flecha/1, wumpus/1, minhacasa/1, orientacao/1, casas_seguras/1]). %fatos dinamicos

wumpusworld(pit3, 4).

init_agent :-                       % se nao tiver nada para fazer aqui, simplesmente termine com um ponto (.)
    writeln('Agente iniciando...'), % apague esse writeln e coloque aqui as acoes para iniciar o agente
    retractall(minhacasa(_)),
    assert(minhacasa([1,1])),       % casa inicial
    retractall(orientacao(_)),
    assert(orientacao(0)),
    retractall(agent_flecha(_)),
    assert(agent_flecha(1)),
    retractall(wumpus(_)),
    assert(wumpus(alive)),
    retractall(casas_seguras(_)),
    assert(casas_seguras([1,1])).

restart_agent :- 
    init_agent.

run_agent(Percepcao, Acao) :-
    write('Percebi: '), 
    writeln(Percepcao),
    agent_flecha(Flecha),nl, % Chamada para recolher o valor da variavel Flecha
    write('Numero de flechas: '), 
    writeln(Flecha),
    minhacasa(Posicao), % Chamada da funcao minhacasa para saber a posicao atual
    write('Minha posicao: '),
    writeln(Posicao),
    adjacentes(Posicao, L), % Chamada da funcao adjacente para obter uma lista de casas adjacentes
    write('Casas adjacentes: '),
    writeln(L),    
    orientacao(Sentido), % Chamada da funcao orientacao para saber a orientacao atual do agente
    write('Sentido do agente: '),
    writeln(Sentido),
    frente(Posicao, Sentido, Frente), % Chamada da funcao frente para saber a casa a frente do agente
    write('Frente: '),
    writeln(Frente),
    estou_sentindo_uma_treta(Percepcao, Acao),
    casas_seguras(Percepcao, Cs), % Chamada da funcao casa segura, dependendo da percepcao do agente
    write('Casas seguras: '),
    writeln(Cs).
   


% Fatos (acoes que vao ser executadas)
estou_sentindo_uma_treta([_,_,_,_,yes]):-
    retractall(wumpus(_)), 
    assert(wumpus(dead)).

estou_sentindo_uma_treta([_,_,no,yes,no], turnleft):-    %fazer agente virar para esquerda ao sentir trombada
    novosentidoleft.

%estou_sentindo_uma_treta([yes,_,_,_,yes], goforward). %agente segue em frente depois de ouvir grito, mesmo sentindo fedor

estou_sentindo_uma_treta([yes,_,_,_,_], shoot) :- 
    agent_flecha(X), 
    X==1, 
    wumpus(alive), 
    tiro. %agente atira ao sentir fedor do wumpus%

estou_sentindo_uma_treta([_,_,no,no,_], goforward):- %agente segue em frente caso nao haja ouro e nao sinta trombada%
    orientacao(Ori),
    novaposicao(Ori).

estou_sentindo_uma_treta([no,no,no,no,no], goforward):-
    orientacao(Ori),
    novaposicao(Ori).

estou_sentindo_uma_treta([_,no,no,no,_], goforward).

%estou_sentindo_uma_treta([_,yes,_,_,_], turnleft):-

estou_sentindo_uma_treta([_,_,yes,_,_],  grab). %agente coleta ouro ao perceber seu brilho%

% Funcoes
tiro :- 
    agent_flecha(X),
    X>0,
    X1 is X-1,
    retractall(agent_flecha(_)),
    assert(agent_flecha(X1)).

casas_seguras([no,no,_,_,_], Cs):-
    minhacasa([X, Y]),
    adjacentes([X, Y], L),
    %not(member([L1,L2,L3,L4], X)),
    %Listadecasasegura=[[1,1]|Calda],
    append([X, Y], L, Cs).

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
    retractall(minhacasa([_|_])),
    assert(minhacasa([X1,Y])).
novaposicao(90):-
    minhacasa([X,Y]),
    Y<4,
    Y1 is Y+1, 
    retractall(minhacasa([_|_])),
    assert(minhacasa([X,Y1])).
novaposicao(90):-
    minhacasa([X,Y]),
    Y==4,
    Y1 is Y, 
    retractall(minhacasa([_|_])),
    assert(minhacasa([X,Y1])).
novaposicao(180):-
    minhacasa([X,Y]),
    X>1,
    X1 is X-1,
    retractall(minhacasa([_|_])),
    assert(minhacasa([X1,Y])).
novaposicao(180):-
    minhacasa([X,Y]),
    X==1,
    X1 is X,
    retractall(minhacasa([_|_])),
    assert(minhacasa([X1,Y])).
novaposicao(270):-
    minhacasa([X,Y]),
    Y>1,
    Y1 is Y-1,
    retractall(minhacasa([_|_])),
    assert(minhacasa([X,Y1])).
novaposicao(270):-
    minhacasa([X,Y]),
    Y==1,
    Y1 is Y,
    retractall(minhacasa([_|_])),
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

