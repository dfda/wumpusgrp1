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
:- dynamic ([agente_flecha/1, wumpus/1, ouro/1, minhacasa/1, orientacao/1, casas_seguras/1, casas_visitadas/1, casa_anterior/1, casas_suspeitas/1, ouro_avista/1]). %fatos dinamicos

wumpusworld(pit3, 4).

init_agent :-                       % se nao tiver nada para fazer aqui, simplesmente termine com um ponto (.)
    writeln('Agente iniciando...'), % apague esse writeln e coloque aqui as acoes para iniciar o agente
    retractall(minhacasa(_)),
    assert(minhacasa([1,1])),       % casa inicial
    retractall(orientacao(_)),
    assert(orientacao(0)),          % orientecao inicial
    retractall(agente_flecha(_)),
    assert(agente_flecha(1)),        % numero inicial de flechas 
    retractall(wumpus(_)),
    assert(wumpus(vivo)),          % estado inicial do wumpus
    retractall(ouro(_)), 
    assert(ouro(0)),                % quantodade inicial de ouro
    retractall(casas_seguras(_)),
    assert(casas_seguras([[1,1]])), % lista inicial de casas seguras
    retractall(casas_visitadas(_)),
    assert(casas_visitadas([[1,1]])), % lista inicial de casas visitadas
    retractall(casa_anterior(_)),
    assert(casa_anterior([1,1])),    % lista inicial de casa anterior
    retractall(casas_suspeitas(_)),
    assert(casas_suspeitas([])),    % lista inicial de casa suspeita
    retractall(ouro_avista(_)),
    assert(ouro_avista([goforward, grab])). %lista a ser executada quando agente vir brilho

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
    write('Casa da frente: '),
    writeln(Frente),
    casa_anterior(Casaanterior),                 % Chamada para saber casa anterior 
    write('Casa anterior: '),
    writeln(Casaanterior),
    faz_casas_visitadas(Posicao),       % Chamada para criar casas visitadas
    casas_visitadas(Casasvisitadas),
    write('Casas visitadas: '),
    writeln(Casasvisitadas),
    faz_casas_seguras(Posicao, L, Percepcao, Csa),  % Chamada para criar casas seguras
    atualiza_casas_seguras(Csa),
    casas_seguras(Casasseguras),   % Chamada da funcao casa segura, dependendo da percepcao do agente
    write('Casas seguras: '),
    writeln(Casasseguras),
    faz_casas_suspeitas(L, Casasseguras, Casasuspeitainicial), % Chamada da funcao para casas suspeitas
    atualiza_casas_suspeitas(Casasuspeitainicial),
    casas_suspeitas(Casassuspeitas),
    write('Casas suspeitas: '),
    writeln(Casassuspeitas),
    agente_flecha(Flecha),           % Chamada para recolher o valor da variavel Flecha
    write('Numero de flechas: '), 
    writeln(Flecha),
    ouro(Quantidade),                        % Chamada para recolher quantidade do ouro 
    write('Quantidade de ouro: '),
    writeln(Quantidade),
    wumpus(Estado),
    write('Estado do Wumpus: '), % Chamada para recolher estado do wumpus
    writeln(Estado),
    estou_sentindo_uma_treta(Percepcao, Acao),
    faz_casa_anterior(Casaanterior).           % Chamada para avaliar se casa anterior esta correta%
    
% Fatos (acoes que vao ser executadas)

% Percepcoes: [Fedor,Vento,Brilho,Trombada,Grito]
% Acoes: goforward, turnright, turnleft, grab, climb, shoot
% Listas: casas_visitadas(Casasvisitadas), casas_seguras(Casasseguras), casas_suspeitas(Casassuspeitas)

% grab (prioridade máxima do agente) [0]
estou_sentindo_uma_treta([_,_,yes,_,_],  grab):- %agente coleta ouro ao perceber seu brilho%
    retractall(ouro(_)),
    assert(ouro(1)),
    write('Estou com ouro !!!'),nl.

% climbs (prioridade) [1]
estou_sentindo_uma_treta([_,_,_,_,_], climb):- %Agente sai da caverna caso possua ouro e esteja na casa [1,1]
    minhacasa([1,1]),
    ouro(1).

estou_sentindo_uma_treta([_,_,_,_,_], climb):- %Agente sai da caverna caso todas as casas ao redor sejam perigosas e esteja na casa [1,1] 
    minhacasa([1,1]), 
    adjacentes([1,1], L),
    casas_suspeitas(Casassuspeitas), 
    subtract(L, Casassuspeitas, Resto),
    Resto == [],  
    write('Eu nao vou morrer aqui, xau! '), nl.

estou_sentindo_uma_treta([_,_,_,_,_], climb):- %Agente sai da caverna caso esteja na casa [1,1] e tenha matado o wumpus
    minhacasa([1,1]),
    wumpus(morto).

estou_sentindo_uma_treta([_,_,_,_,_], climb):- %Agente sai da caverna caso todas as casas seguras tenham sido visitadas
    minhacasa([1,1]),
    casas_visitadas(Casasvisitadas),
    casas_seguras(Casasseguras),
    subtract(Casasseguras, Casasvisitadas, Resto),
    Resto == [],  
    write('Ja visitei todos os lugares seguros, vou nessa! '), nl.

% wumpus dead (procedimentos)
estou_sentindo_uma_treta([_,no,_,_,yes], _):- %Wumpus morto apos agente ouvir o grito%
    retractall(wumpus(_)), 
    assert(wumpus(morto)),
    minhacasa(Posicao),
    orientacao(Sentido),
    casas_seguras(Casasseguras),
    casas_suspeitas(Casassuspeitas),
    faz_frente(Posicao, Sentido, Frente),
    append([Frente], Casasseguras, Casasseguras1),
    retractall(casas_seguras(_)),
    assert(casas_seguras(Casasseguras1)),
    subtract(Casassuspeitas, Casasseguras1, Novassuspeitas),
    retractall(casas_suspeitas(_)),
    assert(casas_suspeitas(Novassuspeitas)), nl,
    write('Ja acabou, Wumpus?'), nl,
    fail.

estou_sentindo_uma_treta([_,yes,_,_,yes], _):- %Wumpus morto apos agente ouvir o grito%
    retractall(wumpus(_)), 
    assert(wumpus(morto)), nl,
    write('Ja acabou, Wumpus?'), nl,
    fail.

% shoot (prioridade) [2]
estou_sentindo_uma_treta([yes,_,_,_,_], shoot) :-  %agente atira caso tenha flecha e wumpus esteja vivo%
    agente_flecha(X), 
    X>0, 
    wumpus(vivo), 
    tiro.

% goforwards (prioridade) [3]
estou_sentindo_uma_treta([_,yes,_,no,_], goforward):-
    minhacasa(Posicao),
    orientacao(Sentido),
    casas_seguras(Casasseguras),
    faz_frente(Posicao, Sentido, Frente),
    member(Frente, Casasseguras),
    retractall(casa_anterior(_)),
    assert(casa_anterior(Posicao)),
    novaposicao(Sentido).

estou_sentindo_uma_treta([yes,_,_,no,_], goforward):-
    minhacasa(Posicao),
    orientacao(Sentido),
    casas_seguras(Casasseguras),
    faz_frente(Posicao, Sentido, Frente),
    member(Frente, Casasseguras),
    retractall(casa_anterior(_)),
    assert(casa_anterior(Posicao)),
    novaposicao(Sentido).

% oritentacoes (prioridade) [4]
estou_sentindo_uma_treta([_,yes,_,_,_], turnleft):-
    minhacasa(Posicao),
    orientacao(Sentido),
    casas_suspeitas(Casassuspeitas),
    faz_frente(Posicao, Sentido, Frente),
    member(Frente, Casassuspeitas),
    novosentidoleft.

%estou_sentindo_uma_treta([_,yes,yes,_,_], Acao):- %Acao caso o agente sinta brisa e brilho
%   minhacasa(Posicao),
%   orientacao(Sentido),
%   casas_seguras(Casasseguras),
%   faz_frente(Posicao, Sentido, Frente),
%   member(Frente, Casasseguras), %vai fazer caso casa da frente seja membro de casas seguras
%   ouro_avista([A|S]),
%   Acao = A,
%   retractall(ouro_avista(_)),
%   assert(ouro_avista(S)).

estou_sentindo_uma_treta([_,_,no,yes,no], turnleft):-    %fazer agente virar para esquerda ao sentir trombada
    novosentidoleft.

estou_sentindo_uma_treta([_,no,no,no,no], goforward):- %agente segue em frente caso todas as percepcoes seja no.
     orientacao(Ori),
     minhacasa(MinhaCasa),
     retractall(casa_anterior(_)),
     assert(casa_anterior(MinhaCasa)),
     novaposicao(Ori).


% Funcoes

calculacao([X1, Y], 0, [X2, Y], goforward):-
    X1<X2,
    orientacao(Ori),
    minhacasa(MinhaCasa),
    retractall(casa_anterior(_)),
    assert(casa_anterior(MinhaCasa)),
    novaposicao(Ori).

calculacao([X1, Y], 0, [X2, Y], turnleft):-
    X1>X2,
    novosentidoleft.

calculacao([X, Y1], 0, [X, Y2], turnleft):-
    Y1<Y2,
    novosentidoleft.

calculacao([X, Y1], 0, [X, Y2], turnright):-
    Y1>Y2,
    novosentidoright.

calculacao([X, Y1], 90, [X, Y2], goforward):-
    Y1<Y2,
    orientacao(Ori),
    minhacasa(MinhaCasa),
    retractall(casa_anterior(_)),
    assert(casa_anterior(MinhaCasa)),
    novaposicao(Ori).

calculacao([X, Y1], 90, [X, Y2], turnleft):-
    Y1>Y2,
    novosentidoleft.

calculacao([X1, Y], 90, [X2, Y], turnleft):-
    X1>X2,
    novosentidoleft.

calculacao([X1, Y], 90, [X2, Y], turnright):-
    X1<X2,
    novosentidoright.

tiro :-  %agente com flecha e capaz de atirar no wumpus e flecha e decrementada%
    agente_flecha(X),
    X>0,
    X1 is X-1,
    retractall(agente_flecha(_)),
    assert(agente_flecha(X1)).

% Predicados para as casas seguras
faz_casas_seguras(Posicao, L, [no,no,_,_,_], Csa):- %casas que sao seguras, com base em casas adjacentes e minha posicao atual%
    append([Posicao], L, Csb),
    list_to_set(Csb, Csa).

faz_casas_seguras(Posicao, _, [_,_,_,_,_], Csa):- % Caso o agente sinta algo, a lista de casas_seguras adiciona a casa da posicao atual do agente
    Csa=[Posicao].

atualiza_casas_seguras(Csa):- % Sempre recebe a variavel Csa para adicionar na lista Cs criando uma nova lista, atualizando a lista de casas seguras
    casas_seguras(Casasseguras),
    append(Csa, Casasseguras, NovaLista1),
    list_to_set(NovaLista1, NovaLista), %list_to_set para retirar casas repetidas da lista atualizada
    retractall(casas_seguras(_)),
    assert(casas_seguras(NovaLista)).

% Predicado para as casas visitadas
faz_casas_visitadas(Posicao) :-  %regra para salvar casas visitadas%
    casas_visitadas(Cv),
    append([Posicao], Cv, NovaLista1),
    list_to_set(NovaLista1, NovaLista),
    retractall(casas_visitadas(_)),
    assert(casas_visitadas(NovaLista)).

% Predicados para a casa anterior
faz_casa_anterior(Casaanterior) :-    %regra para mudar casa anterior caso agente nao mude e casa
    minhacasa([X,Y]),
    casa_anterior([L,M]),
    Y==M,
    X==L,
    retractall(casa_anterior(_)),
    assert(casa_anterior(Casaanterior)).

faz_casa_anterior(_) :-  %regra pra que seja sempre verdade e acao seja retornada para o mundo%
   true.

% Predicados para as casas suspeitas
faz_casas_suspeitas(L, Casasseguras, Casasuspeitainicial):-
    intersection(Casasseguras, L, L1),
    subtract(L, L1, Casasuspeitainicial).

atualiza_casas_suspeitas(Casasuspeitainicial):-
    casas_seguras(Casasseguras),
    casas_suspeitas(Casassuspeitas),
    append(Casasuspeitainicial, Casassuspeitas, NovaLista1),
    list_to_set(NovaLista1, NovaLista),
    subtract(NovaLista, Casasseguras, NovaLista2),
    retractall(casas_suspeitas(_)),
    assert(casas_suspeitas(NovaLista2)).

% Predicados para a casa da frente
faz_frente([4, Y], 0, [4, Y]).      % casa da extremidade, a casa da frente e' a mesma casa que o agente esta
    
faz_frente([X, Y], 0, Frente):-   % caso a orientacao do agente seja 0, a casa da frente sera com o 1o elemento da lista mais 1
    X1 is X + 1,
    Frente=[X1, Y].

faz_frente([X, 4], 90, [X, 4]).     % caso da extremidade, a casa da frente e' a mesma casa que o agente esta
    
faz_frente([X, Y], 90, Frente):-   % caso a orientacao do agente seja 90, a casa da frente sera com o 2o elemento da lista mais 1
    Y1 is Y + 1,
    Frente=[X, Y1].

faz_frente([1, Y], 180, [1, Y]).    % casa invalida, permanece a casa atual como casa da frente
    
faz_frente([X, Y], 180, Frente):-   % caso a orientacao do agente seja 180, a casa da frente sera com o 1o elemento da lista menos 1
    X1 is X - 1,
    Frente=[X1, Y].

faz_frente([X, 1], 270, [X, 1]).    % casa invalida, permanece a casa atual como casa da frente
    
faz_frente([X, Y], 270, Frente):-   % caso a orientacao do agente seja 270, a casa da frente sera com o 2o elemento da lista mais 1
    Y1 is Y - 1,
    Frente=[X, Y1].

% Predicado para orientacao do agente
novosentidoleft:- % muda a memoria do sentido atual caso aconteca um turnleft
    orientacao(Sentido),
    Novosentido is (Sentido+90) mod 360,
    retractall(orientacao(_)),
    assert(orientacao(Novosentido)).
novosentidoright:- % muda a memoria do sentido atual caso aconteca um turnright
    orientacao(Sentido),
    Novosentido is (Sentido-90) mod 360,
    retractall(orientacao(_)),
    assert(orientacao(Novosentido)).

% Predicados para atualizar a posicao atual do agente
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

% Predicados para as casas adjacentes
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

