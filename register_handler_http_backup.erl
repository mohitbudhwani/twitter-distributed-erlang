-module(register_handler_http_backup).
-behavior(cowboy_handler).

-export([init/2,handle/2]).

% init(Req, State) ->
% 	{ok, Req, State}.

% init(Req0, State) ->
%     Req = cowboy_req:reply(200, %status
%         #{<<"content-type">> => <<"text/plain">>}, %headers
%         <<"Hello Erlang!">>, %body / file
%         Req0), %request object

% 	%io:format("~p",[code:priv_dir(twitter)]), %get path of priv folder in project "twitter"
% 	% FileSize=filelib:file_size(code:priv_dir(twitter)++"/registerpage.html"),
% 	% Req = cowboy_req:reply(200, %status
%     %     #{<<"content-type">> => <<"text/plain">>}, %headers
%     %     {sendfile, 0, FileSize, code:priv_dir(twitter) ++ "/registerpage.html"}, %body / file
%     %     Req0), %request object

		
%     {ok, Req, State}.

% init(Req0=#{method := <<"POST">>}, State) ->
%     Req = cowboy_req:reply(200, #{
%             <<"content-type">> => <<"text/plain">>
%             }, <<"Hello worldddddddd yayyy!">>, Req0),

%     {ok, Req, State};

% init(Req0, State) ->
%     io:format("anisha"),
%     Req = cowboy_req:reply(405, #{
%         <<"allow">> => <<"POST">>
%     }, Req0),
    
    
%     % io:format("anisha"),
%     % Req = cowboy_req:reply(200, #{
%     %     <<"content-type">> => <<"text/plain">>
%     %     }, <<"Hello world!">>, Req0),

%     {ok, Req, State}.
    
init(Req0, State) ->
    {ok,Req0,State}.

handle(Req, State) ->
    io:format("ANIHAAAAAA"),
    % {ok, Req2} = cowboy_http_req:reply(200, [{'Content-Type', <<"text/html">>}]),
    {ok, Req2} = cowboy_http_req:reply(404,Req),
    {ok, Req2, State}.

