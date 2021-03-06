/* Wumpusgrp1
*  Disciplina: Logica Matematica
*  Professor: Ruben C. Benante
*  Autores:
*  Alesson Renato Lopes Valenca
*  Cassia Regina Franca Barbosa
*  Rafael de Souza Pereira
*  Wagner Lucas Ferreira da Silva
*/

:- load_files([wumpus3]).
:- dynamic ([agente_flecha/1, 
             wumpus/1, 
             ouro/1, 
             minhacasa/1, 
             orientacao/1, 
             casas_seguras_nao_visitadas/1, 
             casas_seguras/1,
             casas_visitadas/1, 
             casa_anterior/1, 
             casas_suspeitas/1,
             qtdacao/1]). %fatos dinamicos

wumpusworld(pit3, 4).

init_agent :-                      
    writeln('Agente iniciando...'),
    retractall(minhacasa(_)),
    retractall(orientacao(_)),
    retractall(agente_flecha(_)),
    retractall(wumpus(_)),
    retractall(ouro(_)), 
    retractall(casas_seguras_nao_visitadas(_)),
    retractall(casas_seguras(_)),
    retractall(casas_visitadas(_)),
    retractall(casa_anterior(_)),
    retractall(casas_suspeitas(_)),
    retractall(qtdacao(_)),
    assert(minhacasa([1,1])),               % casa inicial
    assert(orientacao(0)),                  % orientecao inicial
    assert(agente_flecha(1)),               % numero inicial de flechas 
    assert(wumpus(vivo)),                   % estado inicial do wumpus
    assert(ouro(0)),                        % quantodade inicial de ouro
    assert(casas_seguras_nao_visitadas([])),% lista inicial de casas seguras nao visitadas
    assert(casas_seguras([])),              % lista inicial de casas seguras
    assert(casas_visitadas([[1,1]])),       % lista inicial de casas visitadas
    assert(casa_anterior([])),              % lista inicial de casa anterior
    assert(casas_suspeitas([])),            % lista inicial de casa suspeita
    assert(qtdacao(0)).                     % quantidade de acoes inicia 0

restart_agent :- 
    init_agent.

run_agent(Percepcao, Acao) :-
    nl,
    write('Informacoes do agente'),
    nl,
    % Fatos %
    minhacasa(Posicao),         % Posicao atual        
    orientacao(Sentido),        % Orientacao atual do agente
    ouro(Quantidade),           % Quantidade do ouro recolhido
    agente_flecha(Flecha),      % Quantidade de flecha
    casa_anterior(Casaanterior), % Casa anterior
    wumpus(Estado),             % Estado do wumpus (vivo/morto)
    qtdacao(Qda),               % Quantidade de acoes 
    % Predicados %
    adjacentes(Posicao, L),     % Funcao adjacente para lista de casas adjacentes
    faz_casas_visitadas,        % Cria casas visitadas
    faz_casas_seguras(Percepcao), % Cria casas seguras
    faz_casas_seguras_nao_visitadas,  % Cria lista casas seguras nao visitadas
    faz_casas_suspeitas(Percepcao), % Cria lista de casas suspeitas
    faz_frente(Posicao, Sentido, Frente), % Casa da frente 
    % Impressao %
    write('Percebi: '), 
    writeln(Percepcao),
    write('Sentido do agente: '),
    writeln(Sentido),
    write('Numero de flechas: '), 
    writeln(Flecha),
    write('Quantidade de ouro: '),
    writeln(Quantidade),
    write('Estado do Wumpus: '),
    writeln(Estado),
    write('Quantidade de acoes: '),
    writeln(Qda),
    write('Minha posicao: '),
    writeln(Posicao),
    write('Casas adjacentes: '),
    writeln(L),
    write('Casa da frente: '),
    writeln(Frente),
    write('Casa anterior: '),
    writeln(Casaanterior),
    estou_sentindo_uma_treta(Percepcao, Acao),
    atualiza_quantidade_acao.

% Percepcoes: [Fedor,Vento,Brilho,Trombada,Grito]
% Acoes: goforward, turnright, turnleft, grab, climb, shoot
% Listas: casas_visitadas(Casasvisitadas), casas_seguras_nao_visitadas(CasasSegurasNV), casas_suspeitas(Casassuspeitas)

atualiza_quantidade_acao:-
    qtdacao(Qda),
    Qda1 is Qda+1,
    retractall(qtdacao(_)),
    assert(qtdacao(Qda1)).

% Acoes que vao ser executadas
% grab (prioridade máxima do agente) [0]
estou_sentindo_uma_treta([_,_,yes,_,_],  grab):- %agente coleta ouro ao perceber seu brilho%
    retractall(ouro(_)),
    assert(ouro(1)),
    write('Estou com ouro !!!'),nl.
    
% shoot (prioridade) [1]
estou_sentindo_uma_treta([yes,no,_,_,_], shoot) :-  %agente atira caso tenha flecha, sinta o cheiro e wumpus vivo%
    agente_flecha(X), 
    X>0, 
    wumpus(vivo), 
    tiro,
    minhacasa(Posicao),
    orientacao(Sentido),
    faz_frente(Posicao, Sentido, Frente),
    casas_seguras_nao_visitadas(CasassegurasNV),
    casas_seguras(CasasSeguras),
    append([Frente], CasasSeguras, CasasSeg),
    append([Frente], CasassegurasNV, CasasSegnv1),
    retractall(casas_seguras_nao_visitadas(_)),
    assert(casas_seguras_nao_visitadas(CasasSegnv1)),
    retractall(casas_seguras(_)),
    assert(casas_seguras(CasasSeg)).
        
estou_sentindo_uma_treta([yes,yes,_,_,_], shoot) :-  %agente atira caso tenha flecha, sinta cheiro e brisa e wumpus vivo
    agente_flecha(X), 
    X>0, 
    wumpus(vivo), 
    tiro.

% climbs (prioridade) [2]
estou_sentindo_uma_treta(_, climb):- % Passou da quantidade de acoe? Sai da caverna logo
    qtdacao(Qda),
    Qda>49,
    minhacasa([1,1]).

estou_sentindo_uma_treta(_, climb):- %Agente sai da caverna caso possua ouro e esteja na casa [1,1]
    minhacasa([1,1]),
    ouro(1).
    
estou_sentindo_uma_treta(_, climb):- %Agente sai da caverna caso todas as casas ao redor sejam perigosas e esteja na casa [1,1]
    minhacasa([1,1]), 
    adjacentes([1,1], L),  
    casas_suspeitas(CasasSuspeitas),
    L==CasasSuspeitas,
    write('Eu nao vou morrer aqui, xau! '), nl.
    
estou_sentindo_uma_treta(_, climb):- %Agente sai da caverna caso esteja na casa [1,1] e tenha matado o wumpus e visitou todas as casas seguras nao visitdas
    minhacasa([1,1]),
    casas_seguras_nao_visitadas([]),
    wumpus(morto).
    
estou_sentindo_uma_treta(_, climb):- %Agente sai da caverna caso todas as casas seguras tenham sido visitadas
    minhacasa([1,1]),
    casas_seguras_nao_visitadas([]),
    write('Ja visitei todos os lugares seguros, vou nessa!'), nl.
   
% wumpus dead (procedimentos)
estou_sentindo_uma_treta([_,no,_,_,yes], _):- %Wumpus morto apos agente ouvir o grito, atualiza lista de casas segura, casas nao visitadas e suspeitas
    retractall(wumpus(_)), 
    assert(wumpus(morto)),
    minhacasa(Posicao),
    casas_seguras(CasasSeg),
    casas_seguras_nao_visitadas(CasasSegurasNV),
    casas_suspeitas(Casassuspeitas),
    adjacentes(Posicao, L),
    append(L, CasasSegurasNV, CasasSegurasNV1),
    retractall(casas_seguras_nao_visitadas(_)),
    assert(casas_seguras_nao_visitadas(CasasSegurasNV1)),
    append(L, CasasSeg, CasasSeguras),
    retractall(casas_seguras(_)),
    assert(casas_seguras(CasasSeguras)),
    subtract(Casassuspeitas, CasasSeguras, Novassuspeitas),
    retractall(casas_suspeitas(_)),
    assert(casas_suspeitas(Novassuspeitas)), nl,
    write('Ja acabou, Wumpus?'), nl,
    fail.

estou_sentindo_uma_treta([_,yes,_,_,yes], _):- %Wumpus morto apos agente ouvir o grito%
    retractall(wumpus(_)), 
    assert(wumpus(morto)), nl,
    write('Ja acabou, Wumpus?'), nl,
    fail.

% goforwards e turnleft (prioridade) [3]
%----------------------------------------------------%
estou_sentindo_uma_treta(_, Acao):- % Quando quantidade maxima de acoe e' maior que 49, o agente prioriza o retorno a casa [1,1] 
    qtdacao(Qda),
    Qda>49,
    minhacasa(Posicao),
    orientacao(Sentido),
    calculacao(Posicao, Sentido, [1,1], Acao).

estou_sentindo_uma_treta(_, Acao):- % Quando a lista de casas seguras e' vazia, o agente prioriza o retorno a casa [1,1]
    casas_seguras_nao_visitadas([]),
    minhacasa(Posicao),
    orientacao(Sentido),
    calculacao(Posicao, Sentido, [1,1], Acao).

estou_sentindo_uma_treta([_,_,no,yes,no], turnleft):-    %fazer agente virar para esquerda ao sentir trombada
    novosentidoleft.

% Acoes para o agente visitar casas seguras nao visitadas
estou_sentindo_uma_treta(_, Acao):-
    casas_seguras_nao_visitadas(CasasSegurasNV),
    minhacasa(Posicao),
    orientacao(Sentido),
    faz_frente(Posicao, 0, Frente), % Qual e' a casa da frente com sentido 0
    member(Frente, CasasSegurasNV), % Faz parte de casas nao visitdadas?
    acao(Sentido, 0, Acao). % Qual acao devo fazer?

estou_sentindo_uma_treta(_, Acao):-
    casas_seguras_nao_visitadas(CasasSegurasNV),
    minhacasa(Posicao),
    orientacao(Sentido),
    faz_frente(Posicao, 90, Frente),
    member(Frente, CasasSegurasNV),
    acao(Sentido, 90, Acao).

estou_sentindo_uma_treta(_, Acao):-
    casas_seguras_nao_visitadas(CasasSegurasNV),
    minhacasa(Posicao),
    orientacao(Sentido),
    faz_frente(Posicao, 180, Frente),
    member(Frente, CasasSegurasNV),
    acao(Sentido, 180, Acao).

estou_sentindo_uma_treta(_, Acao):-
    casas_seguras_nao_visitadas(CasasSegurasNV),
    minhacasa(Posicao),
    orientacao(Sentido),
    faz_frente(Posicao, 270, Frente),
    member(Frente, CasasSegurasNV),
    acao(Sentido, 270, Acao).

% Acoes para o agente voltar pelas casas visitadas
estou_sentindo_uma_treta(_, Acao):-
    casas_visitadas(CasasVisitadas),
    minhacasa(Posicao),
    orientacao(Sentido),
    faz_frente(Posicao, 0, Frente), % Qual e' a casa da frente com sentido 0
    member(Frente, CasasVisitadas), % Faz parte de casas visitadas?
    acao(Sentido, 0, Acao). % Qual acao devo fazer?

estou_sentindo_uma_treta(_, Acao):-
    casas_visitadas(CasasVisitadas),
    minhacasa(Posicao),
    orientacao(Sentido),
    faz_frente(Posicao, 90, Frente),
    member(Frente, CasasVisitadas),
    acao(Sentido, 90, Acao).

estou_sentindo_uma_treta(_, Acao):-
    casas_visitadas(CasasVisitadas),
    minhacasa(Posicao),
    orientacao(Sentido),
    faz_frente(Posicao, 180, Frente),
    member(Frente, CasasVisitadas),
    acao(Sentido, 180, Acao).

estou_sentindo_uma_treta(_, Acao):-
    casas_visitadas(CasasVisitadas),
    minhacasa(Posicao),
    orientacao(Sentido),
    faz_frente(Posicao, 270, Frente),
    member(Frente, CasasVisitadas),
    acao(Sentido, 270, Acao).

% Escolha das acoes
acao(Sentido1, Sentido2, goforward):-
    Sentido1==Sentido2, % Sentidos iguais, anda
    faz_casa_anterior,
    novaposicao.

acao(Sentido1, Sentido2, turnleft):-
    Sentido1\==Sentido2, % Sentidos diferente, turnleft
    novosentidoleft.

% Funcoes
%-----------------------------------------------------%
% Calculacao sentido 0
calculacao([X1, Y], 0, [X2, Y], goforward):-
    X1<X2,
    casas_seguras(CasasSeguras),
    minhacasa(Posicao),
    faz_frente(Posicao, 0, Frente),
    member(Frente, CasasSeguras),
    faz_casa_anterior,
    novaposicao.

calculacao([X1, Y], 0, [X2, Y], turnleft):-
    X1>X2,
    novosentidoleft.

calculacao([X, Y1], 0, [X, Y2], turnleft):-
    Y1<Y2,
    novosentidoleft.

calculacao([X, Y1], 0, [X, Y2], turnright):-
    Y1>Y2,
    novosentidoright.

calculacao([X1, Y1], 0, [X2, Y2], turnright):-
    X1>X2,
    Y1>Y2,
    novosentidoright.

calculacao([X1, Y1], 0, [X2, Y2], goforward):-
    X1<X2,
    Y1>Y2,
    casas_seguras(CasasSeguras),
    minhacasa(Posicao),
    faz_frente(Posicao, 0, Frente),
    member(Frente, CasasSeguras),
    faz_casa_anterior,
    novaposicao.

calculacao([X1, Y1], 0, [X2, Y2], turnleft):-
    X1>X2,
    Y1<Y2,
    novosentidoleft.

calculacao([X1, Y1], 0, [X2, Y2], goforward):-
    X1<X2,
    Y1<Y2,
    casas_seguras(CasasSeguras),
    minhacasa(Posicao),
    faz_frente(Posicao, 0, Frente),
    member(Frente, CasasSeguras),
    faz_casa_anterior,
    novaposicao.

% Calculacao sentido 90
calculacao([X, Y1], 90, [X, Y2], goforward):-
    Y1<Y2,
    casas_seguras(CasasSeguras),
    minhacasa(Posicao),
    faz_frente(Posicao, 90, Frente),
    member(Frente, CasasSeguras),
    faz_casa_anterior,
    novaposicao.

calculacao([X, Y1], 90, [X, Y2], turnleft):-
    Y1>Y2,
    novosentidoleft.

calculacao([X1, Y], 90, [X2, Y], turnleft):-
    X1>X2,
    novosentidoleft.

calculacao([X1, Y], 90, [X2, Y], turnright):-
    X1<X2,
    novosentidoright.

calculacao([X1, Y1], 90, [X2, Y2], turnleft):-
    X1>X2,
    Y1>Y2,
    novosentidoleft.

calculacao([X1, Y1], 90, [X2, Y2], turnright):-
    X1<X2,
    Y1>Y2,
    novosentidoright.

calculacao([X1, Y1], 90, [X2, Y2], goforward):-
    X1>X2,
    Y1<Y2,
    casas_seguras(CasasSeguras),
    minhacasa(Posicao),
    faz_frente(Posicao, 90, Frente),
    member(Frente, CasasSeguras),
    faz_casa_anterior,
    novaposicao.

calculacao([X1, Y1], 90, [X2, Y2], goforward):-
    X1<X2,
    Y1<Y2,
    casas_seguras(CasasSeguras),
    minhacasa(Posicao),
    faz_frente(Posicao, 90, Frente),
    member(Frente, CasasSeguras),
    faz_casa_anterior,
    novaposicao.

% Calculacao sentido 180
calculacao([X1, Y], 180, [X2, Y], turnleft):-
    X1<X2,
    novosentidoleft.

calculacao([X1, Y], 180, [X2, Y], goforward):-
    X1>X2,
    casas_seguras(CasasSeguras),
    minhacasa(Posicao),
    faz_frente(Posicao, 180, Frente),
    member(Frente, CasasSeguras),
    faz_casa_anterior,
    novaposicao.

calculacao([X, Y1], 180, [X, Y2], turnright):-
    Y1<Y2,
    novosentidoright.

calculacao([X, Y1], 180, [X, Y2], turnleft):-
    Y1>Y2,
    novosentidoleft.

calculacao([X1, Y1], 180, [X2, Y2], goforward):-
    X1>X2,
    Y1<Y2,
    casas_seguras(CasasSeguras),
    minhacasa(Posicao),
    faz_frente(Posicao, 180, Frente),
    member(Frente, CasasSeguras),
    faz_casa_anterior,
    novaposicao.

calculacao([X1, Y1], 180, [X2, Y2], turnleft):-
    X1<X2,
    Y1>Y2,
    novosentidoleft.

calculacao([X1, Y1], 180, [X2, Y2], turnright):-
    X1<X2,
    Y1<Y2,
    novosentidoright.

calculacao([X1, Y1], 180, [X2, Y2], goforward):-
    X1>X2,
    Y1>Y2,
    casas_seguras(CasasSeguras),
    minhacasa(Posicao),
    faz_frente(Posicao, 180, Frente),
    member(Frente, CasasSeguras),
    faz_casa_anterior,
    novaposicao.

% calculacao sentido 270
calculacao([X1, Y], 270, [X2, Y], turnleft):-
    X1<X2,
    novosentidoleft.

calculacao([X1, Y], 270, [X2, Y], turnright):-
    X1>X2,
    novosentidoright.

calculacao([X, Y1], 270, [X, Y2], goforward):-
    Y2<Y1,
    casas_seguras(CasasSeguras),
    minhacasa(Posicao),
    faz_frente(Posicao, 270, Frente),
    member(Frente, CasasSeguras),
    faz_casa_anterior,
    novaposicao.

calculacao([X, Y1], 270, [X, Y2], turnleft):-
    Y2>Y1,
    novosentidoleft.

calculacao([X1, Y1], 270, [X2, Y2], goforward):-
    X1>X2,
    Y1>Y2,
    faz_casa_anterior,
    casas_seguras(CasasSeguras),
    minhacasa(Posicao),
    faz_frente(Posicao, 270, Frente),
    member(Frente, CasasSeguras),
    novaposicao.

calculacao([X1, Y1], 270, [X2, Y2], goforward):-
    X1<X2,
    Y1>Y2,
    faz_casa_anterior,
    casas_seguras(CasasSeguras),
    minhacasa(Posicao),
    faz_frente(Posicao, 270, Frente),
    member(Frente, CasasSeguras),
    novaposicao.

calculacao([X1, Y1], 270, [X2, Y2], turnleft):-
    X1<X2,
    Y1<Y2,
    novosentidoleft.

calculacao([X1, Y1], 270, [X2, Y2], turnright):-
    X1>X2,
    Y1<Y2,
    novosentidoright.

tiro :-  %agente com flecha e capaz de atirar no wumpus e flecha e decrementada%
    agente_flecha(X),
    X>0,
    X1 is X-1,
    retractall(agente_flecha(_)),
    assert(agente_flecha(X1)).
%-----------------------------------------------------%
% Predicados para casas seguras
faz_casas_seguras([no,no,_,_,_]):- %casas que sao seguras, com base em casas adjacentes e minha posicao atual%
    minhacasa(Posicao),
    adjacentes(Posicao, L),
    append([Posicao], L, Csb),
    list_to_set(Csb, Csa),
    atualiza_casas_seguras(Csa).

faz_casas_seguras([yes,no,_,_,_]):- %casas que sao seguras, caso wumpus morto, com base em casas adjacentes e minha posicao atual
    minhacasa(Posicao),
    adjacentes(Posicao, L),
    wumpus(morto),
    append([Posicao], L, Csb),
    list_to_set(Csb, Csa),
    atualiza_casas_seguras(Csa).

faz_casas_seguras(_):- % Caso o agente sinta algo, a lista de casas_seguras adiciona a casa da posicao atual do agente
    minhacasa(Posicao),
    Csa=[Posicao],
    atualiza_casas_seguras(Csa).

atualiza_casas_seguras(Csa):- % Sempre recebe a variavel Csa para adicionar na lista Cs criando uma nova lista, atualizando a lista de casas seguras
    casas_seguras(CasasSeguras),
    append(Csa, CasasSeguras, NovaLista1),
    list_to_set(NovaLista1, NovaLista), %list_to_set para retirar casas repetidas da lista atualizada
    retractall(casas_seguras(_)),
    assert(casas_seguras(NovaLista)),
    write('Casas seguras: '),
    writeln(NovaLista).
%---------------------------------------------------------%
% Predicado para as casas visitadas
faz_casas_visitadas:-  %regra para salvar casas visitadas%
    minhacasa(Posicao),
    casas_visitadas(Cv),
    append([Posicao], Cv, NovaLista1),
    list_to_set(NovaLista1, NovaLista),
    retractall(casas_visitadas(_)),
    assert(casas_visitadas(NovaLista)),
    write('Casas visitadas: '),
    writeln(NovaLista).
%---------------------------------------------------------%
%% Predicados para as casas seguras nao visitados
faz_casas_seguras_nao_visitadas:-
    casas_seguras(CasasSeguras),
    casas_visitadas(CasasVisitadas),
    subtract(CasasSeguras, CasasVisitadas, CasasSegurasNV1),
    subtract(CasasSegurasNV1, [[0,_],[_,0],[5,_],[_,5]], CasasSegurasNV),
    retractall(casas_seguras_nao_visitadas(_)),
    assert(casas_seguras_nao_visitadas(CasasSegurasNV)),
    write('Casas seguras nao visitadas: '),
    writeln(CasasSegurasNV).
%------------------------------------------------------%
% Predicados para a casa anterior
faz_casa_anterior :-    %regra para mudar casa anterior caso agente nao mude e casa
    minhacasa(MinhaCasa),
    retractall(casa_anterior(_)),
    assert(casa_anterior(MinhaCasa)).
%---------------------------------------------------------%
% Predicados para as casas suspeitas
faz_casas_suspeitas([yes,no|_]):- % Agente percebeu fedor, atualiza as casas suspeitas
    minhacasa(Posicao),
    adjacentes(Posicao, L),
    casas_visitadas(CasasVisitadas),
    intersection(CasasVisitadas, L, L1), % Intersecao das casas visitadas com as casas adjacentes
    subtract(L, L1, CasaSuspeitaInicial), % Subtrair a lista com as intersecoes da adjacente
    atualiza_casas_suspeitas(CasaSuspeitaInicial).

faz_casas_suspeitas([no,yes|_]):- % Agente percebeu brisa, atualiza casas suspeitas
    minhacasa(Posicao),
    adjacentes(Posicao, L),
    casas_visitadas(CasasVisitadas),
    intersection(CasasVisitadas, L, L1), % Intersecao das casas visitadas com as casas adjacentes
    subtract(L, L1, CasaSuspeitaInicial), % Subtrair a lista com as intersecoes da adjacente
    atualiza_casas_suspeitas(CasaSuspeitaInicial).

faz_casas_suspeitas([yes,yes|_]):- % Agente percebeu brisa e fedor, atualiza casas suspeitas
    minhacasa(Posicao),
    adjacentes(Posicao, L),
    casas_visitadas(CasasVisitadas),
    intersection(CasasVisitadas, L, L1), % Intersecao das casas visitadas com as casas adjacentes
    subtract(L, L1, CasaSuspeitaInicial), % Subtrair a lista com as intersecoes da adjacente
    atualiza_casas_suspeitas(CasaSuspeitaInicial).

faz_casas_suspeitas([no,no|_]):- % Agente nao percebeu fedor ou vento, nao atualiza casas suspeitas
    casas_suspeitas(CasasSuspeitas),
    write('Casas suspeitas: '),
    writeln(CasasSuspeitas),
    true.

atualiza_casas_suspeitas(Casasuspeitainicial):-
    casas_seguras(Casasseguras), % casas seguras atuais
    casas_suspeitas(Casassuspeitas), % casas suspeitas atuais
    append(Casasuspeitainicial, Casassuspeitas, NovaLista1), % adicionar a lista do predicado anterior na lista de casa suspeita atual
    list_to_set(NovaLista1, NovaLista), % retirar casas iguais
    subtract(NovaLista, Casasseguras, NovaLista2), % retirar as casas seguras da lista
    retractall(casas_suspeitas(_)),
    assert(casas_suspeitas(NovaLista2)), % atualizar a lista
    write('Casas suspeitas: '),
    writeln(NovaLista2).
   
%-----------------------------------------------------%
% Predicados para a casa da frente
    
faz_frente([X, Y], 0, [X1, Y]):-   % caso a orientacao do agente seja 0, a casa da frente sera com o 1o elemento da lista mais 1
    X1 is X + 1.
    
faz_frente([X, Y], 90, [X, Y1]):-   % caso a orientacao do agente seja 90, a casa da frente sera com o 2o elemento da lista mais 1
    Y1 is Y + 1.

faz_frente([X, Y], 180, [X1, Y]):-   % caso a orientacao do agente seja 180, a casa da frente sera com o 1o elemento da lista menos 1
    X1 is X - 1.

faz_frente([X, Y], 270, [X, Y1]):-   % caso a orientacao do agente seja 270, a casa da frente sera com o 2o elemento da lista mais 1
    Y1 is Y - 1.
%-----------------------------------------------------%
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
%-----------------------------------------------------%
% Predicados para atualizar a posicao atual do agente
novaposicao:- 
    orientacao(0),
    minhacasa([X,Y]),
    X<4,
    X1 is X+1,   
    retractall(minhacasa(_)),
    assert(minhacasa([X1,Y])).

novaposicao:- 
    orientacao(0),
    minhacasa([X,Y]),
    X==4,
    X1 is X,  
    retractall(minhacasa(_)),
    assert(minhacasa([X1,Y])).

novaposicao:-
    orientacao(90),
    minhacasa([X,Y]),
    Y<4,
    Y1 is Y+1, 
    retractall(minhacasa(_)),
    assert(minhacasa([X,Y1])).

novaposicao:-
    orientacao(90),
    minhacasa([X,Y]),
    Y==4,
    Y1 is Y, 
    retractall(minhacasa(_)),
    assert(minhacasa([X,Y1])).

novaposicao:-
    orientacao(180),
    minhacasa([X,Y]),
    X>1,
    X1 is X-1,
    retractall(minhacasa(_)),
    assert(minhacasa([X1,Y])).

novaposicao:-
    orientacao(180),
    minhacasa([X,Y]),
    X==1,
    X1 is X,
    retractall(minhacasa(_)),
    assert(minhacasa([X1,Y])).

novaposicao:-
    orientacao(270),
    minhacasa([X,Y]),
    Y>1,
    Y1 is Y-1,
    retractall(minhacasa(_)),
    assert(minhacasa([X,Y1])).

novaposicao:-
    orientacao(270),
    minhacasa([X,Y]), 
    Y==1,
    Y1 is Y,
    retractall(minhacasa(_)),
    assert(minhacasa([X,Y1])).
%-----------------------------------------------------%
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
%-----------------------------------------------------%
% Funcoes para calcular as coordenadas das casas adjacentes
cima([X, Y], [X, Y1]):-
    Y1 is Y + 1.

baixo([X, Y], [X, Y2]):-
    Y2 is Y - 1.

esquerda([X, Y], [X2, Y]):-
    X2 is X - 1.

direita([X, Y], [X1, Y]):-
    X1 is X + 1.

