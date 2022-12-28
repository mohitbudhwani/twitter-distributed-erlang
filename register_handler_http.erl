-module(register_handler_http).
-behavior(cowboy_handler).

-export([init/2,handle/2]).

init(Req0, State) ->
	io:format("helllo anishaaaa"),
    % Req = cowboy_req:reply(200,
    %     #{<<"content-type">> => <<"text/plain">>},
    %     <<"Hello Erlang!">>,
    %     Req0),
    % {ok, Req, State}.
    % 
	io:format("~p\n\n\n",[Req0]),
	io:format("~p\n",[State]),
    {ok,Req0,State}.

handle(_Req, State) ->
    io:format("ANIHAAAAAA"),
    {ok, Req2} = cowboy_http_req:reply(200, [{'Content-Type', <<"text/html">>}]),
    
    {ok, Req2, State}.
