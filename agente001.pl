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
:- dynamic ([agent_flecha/1, wumpus/1, minhacasa/1, orientacao/1]). %fatos dinamicos

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
    assert(wumpus(alive)).
% esta funcao permanece a mesma. Nao altere.
restart_agent :- 
    init_agent.

% esta e a funcao chamada pelo simulador. Nao altere a "cabeca" da funcao. Apenas o corpo.
% Funcao recebe Percepcao, uma lista conforme descrito acima.
% Deve retornar uma Acao, dentre as acoes validas descritas acima.
run_agent(Percepcao, Acao) :-
    write('Percebi: '), 
    writeln(Percepcao),
    agent_flecha(Flecha),nl,
    write('Numero de flechas: '), 
    writeln(Flecha),
    minhacasa(Posicao),
    write('Minha posicao: '),
    writeln(Posicao),
    orientacao(Sentido),
    write('Sentido do agente: '),
    writeln(Sentido),
    estou_sentindo_uma_treta(Percepcao, Acao).

% Fatos (acoes que vao ser executadas)
estou_sentindo_uma_treta([_,_,_,_,yes]):-
    retractall(wumpus(_)), 
    assert(wumpus(dead)).

estou_sentindo_uma_treta([_,_,no,yes,no], turnleft):-    %fazer agente virar para esquerda ao sentir trombada
    novosentido,
    novaposicao.

%estou_sentindo_uma_treta([yes,_,_,_,yes], goforward). %agente segue em frente depois de ouvir grito, mesmo sentindo fedor

estou_sentindo_uma_treta([yes,_,_,_,_], shoot) :- 
    agent_flecha(X), 
    X==1, 
    wumpus(alive), 
    tiro. %agente atira ao sentir fedor do wumpus%

estou_sentindo_uma_treta([_,_,no,no,_], goforward):- %agente segue em frente caso nao haja ouro e nao sinta trombada%
    novaposicao.

%estou_sentindo_uma_treta([_,yes,_,_,_], turnleft):-

estou_sentindo_uma_treta([_,_,yes,_,_],  grab). %agente coleta ouro ao perceber seu brilho%

tiro :- 
    agent_flecha(X),
    X>0,
    X1 is X-1,
    retractall(agent_flecha(_)),
    assert(agent_flecha(X1)).
novosentido :-   
    orientacao(S),
    S1 is (S+90) mod 360,
    retractall(orientacao(_)),
    assert(orientacao(S1)).
novaposicao :-
    minhacasa([X,Y]),
    orientacao(O),    
    O==0,
    X1 is X+1,  %Necessario validar a posicao
    retractall(minhacasa([_|_])),
    assert(minhacasa([X1,Y])).
novaposicao :-
    minhacasa([X,Y]),
    orientacao(O),    
    O==90,
    Y1 is Y+1, %Necessario validar e limitar posicao de Y ate 4
    retractall(minhacasa([_|_])),
    assert(minhacasa([X,Y1])).

%para recolhimento de listas
membro(X,[X|_]).
membro(X, [_|Y]):-
    membro(X,Y).

% Casas adjacentes
minhacasa([H, T]):-
    adjacentes([H, T], L).

adjacentes([H, T], L):-
    cima([H, T], L1),
    baixo([H, T], L2),
    esqueda([H, T], L3),
    direita([H, T], L4),
    L=[L1, L2, L3, L4],
    write('Adjacentes: '),
    writeln(L).

cima([H, T], L1):-
    not(H==4),
    H1 is H+1,
    L1=[H1, T].
