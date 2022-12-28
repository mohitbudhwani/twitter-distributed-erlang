-module(register_handler).
-behavior(cowboy_websocket).

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).

init(Req, State) ->
	io:format("anisha 0\n"),
	io:format("~p\n",[Req]),
	io:format("~p\n",[State]),
	{cowboy_websocket, Req, State}.

websocket_init(State) ->
	io:format("anisha 1"),
	% cowboy_req:reply(200, #{
    %     <<"content-type">> => <<"text/plain">>
    %     }, <<"Hello world!">>, Req0),

	%{State}.
	%{ok, Req, State}.
	{[], State}.


websocket_handle({text, Data}, State) ->
	io:format("anisha 2"),
	{[{text, Data}], State};
websocket_handle({binary, Data}, State) ->
	io:format("anisha 3"),
	{[{binary, Data}], State};
websocket_handle(_Frame, State) ->
	io:format("anisha 4"),
	{[], State}.

websocket_info(_Info, State) ->
	{[], State}.
