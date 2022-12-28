-module(twitter_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	
	ServerPID = twitterserver:start_server(),

	Dispatch = cowboy_router:compile([
		%% {HostMatch, list({PathMatch, Handler module name (erl), InitialState})}
        {'_', [
			%{"/registerpage.html", register_handler_http, []}, %working but replaces page content with response 
			% {"/homepage.html", feed_handler, []},
			% {"/twitter/[:var]", register_handler, []},
			%{"/twitter/:var", feed_handler, []},

			{"/[...]", cowboy_static, {priv_dir, twitter, "assets"}}]}  % html pages path ; static file ; lesson: only the first cowboy_static statement will work
		
		%{'_', [{"/[...]", cowboy_static, {priv_file, twitter, "/registerpage.html"}}]}, % html pages path ; static file ; wont work along with above ; move file to priv folder to work
		
		%{'_', [{"/", register_handler_http, []}]}, % handler for the url /home; to handle requests 
		%{'_', [{"/twitter/", register_handler_http, []}]}, % handler for the url /home; to handle requests 
		%{'_', [{"/twitter/homepage", register_handler_http, []}]} % handler for the url /home; to handle requests 
		% {'_', [{"/", register_handler_http, []}]} % handler for the url /home; to handle requests 
		%{'_', [{"/twitter/registerpage.html", register_handler_http, []}]} % handler for the url /home; to handle requests 

		%{'_', [{"/twitter/registerpage.html", register_handler, []}]} % handler for the url /home; to handle requests 
		%{handler, disrupt_chat_handler}, {channel, ChannelPid}
    ]),


	%StateMap = #{selfPid=>self()},
	DispatchWs = cowboy_router:compile([
		{'_', [
			{"/homepage.html", feed_handler, [{serverPID,ServerPID}]}
		]}
	  ]),
	
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),

	{ok, _} = cowboy:start_clear(ws,[{port, 8889}],
	#{env => #{dispatch => DispatchWs}}),
 
	twitter_sup:start_link().

stop(_State) ->
	ok.
