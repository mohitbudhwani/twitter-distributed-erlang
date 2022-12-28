-module(client).

-export([register/4,subscribe/1,profileHandler/6,extractHashTag/1,extractMention/1,findSymbol/4]).

register(ServerPID,HandlerPID,Username,_Password)->
    PID = spawn_link(client,profileHandler,[ServerPID,HandlerPID,Username,[],[],[]]),
    ServerPID ! {newUser,Username,PID},
    PID. %Print statement

subscribe(Username)->
    self() ! {subscribe,Username}. %check if it goes into profileHandler

profileHandler(ServerPID,HandlerPID,Username,SubscriberList,SelfTweetList,SubscribedTweetList)->
    %io:format("sub ~p~n",[SubscriberList]),
    receive


        {subscribeToUser2,User2}-> %Message from Handler to subscribe to user2's content
            ServerPID! {getUserPIDforSubscribtion,self(),User2}, %Message to Server requesting for PID of user2 
            profileHandler(ServerPID,HandlerPID,Username,SubscriberList,SelfTweetList,SubscribedTweetList);

        {subscribtionPID,User2PID}-> %Message from server with PID of user2
            User2PID! {subscriber,Username}, 
            profileHandler(ServerPID,HandlerPID,Username,SubscriberList,SelfTweetList,SubscribedTweetList);

        %messages from simulator% 
        %message from User1 who is now subscribed to User2
        {subscriber,User2}->
            %io:format("\nDEBUG : ~p Subscriber list ~p~n",[self(),SubscriberList]),
            profileHandler(ServerPID,HandlerPID,Username,[User2]++SubscriberList,SelfTweetList,SubscribedTweetList);
                
        % {searchHashTag,HashTag}->
        %     ServerPID ! {getTweetHashTag,HashTag},
        %     io:format("[~p FEED] ~p : ~p ~n",[Username,User,TweetBody]),

        %messages for server - client interaction%
        {newTweetFeed,User,TweetBody} ->
            io:format("\n\n [~p FEED] ~p : ~p ~n",[Username,User,TweetBody]),
            io:format("Handler ~p and self ~p",[HandlerPID,self()]),
            HandlerPID ! {updateFeed,{User,TweetBody}},
            %io:format("Timestamp ~p",os:timestamp()),
            profileHandler(ServerPID,HandlerPID,Username,SubscriberList,SelfTweetList,SubscribedTweetList++[{User,TweetBody}]);

        
           
        {sendTweet,TweetBody}->
            %lists:foreach(fun(P)-> ServerPID! {sendTweet, Username, P, TweetBody} end,SubscriptionList),
            % io:format("Timestamp ~p",os:timestamp()),
            % io:format("sending server the subscriber list ~p~n",[SubscriberList]),
            ServerPID ! {tweet,Username,SubscriberList,TweetBody},

            %check for hashtags 
            HashTagList = extractHashTag(TweetBody),
            % if length(HashTagList)>0->
            %     io:format("Hashtags found ~p~n",[HashTagList]);
            %     true->
            %         io:format("")
            %     end,
            lists:foreach(fun(HT)->ServerPID ! {hashtag,Username,TweetBody,HT} end,HashTagList),

            % check for mentions
            MentionList = extractMention(TweetBody),
            % if length(MentionList)>0->
            %     io:format("Mentions found ~p~n",[MentionList]);
            %     true->
            %         io:format("")
            %     end,
            lists:foreach(fun(M)->ServerPID ! {mention,Username,TweetBody,M} end,MentionList),
            % send message to mentions
            if length(MentionList) > 0 ->
                ServerPID ! {tweet,Username,MentionList,TweetBody};
            true ->
                ok
            end,

            profileHandler(ServerPID,HandlerPID,Username,SubscriberList,SelfTweetList++[TweetBody],SubscribedTweetList);

        {retweet,User,TweetBody}->
            %io:format("Timestamp ~p",os:timestamp()),
            TweetPattern = fun(T) -> element(2,T) == TweetBody end,
            %io:fwrite("ANISHA ~w ~n",[SubscribedTweetList]),
            Found = lists:any(TweetPattern,SubscribedTweetList),
            if Found == true ->
                ServerPID ! {tweet,Username,SubscriberList,"[Retweet] "++User++":"++TweetBody},
                profileHandler(ServerPID,HandlerPID,Username,SubscriberList,SelfTweetList++[TweetBody],SubscribedTweetList);
                true ->
                   io:format("Tweet not found ~n"),
                   profileHandler(ServerPID,HandlerPID,Username,SubscriberList,SelfTweetList,SubscribedTweetList),
                   ok
            end;

        {search_hashtag,QueryKeyword}->
            io:format("ANISHA search hashtag"),
            HashTag = string:sub_string(QueryKeyword, 2),
            ServerPID ! {getHashTag,self(),HashTag},
            profileHandler(ServerPID,HandlerPID,Username,SubscriberList,SelfTweetList,SubscribedTweetList);

        {tweetByHashtag,HashTag,HashTagList}->
            %io:format("Timestamp ~p",os:timestamp()),
            HandlerPID ! {searchResult,{hashtag,HashTag,HashTagList}},
            io:format("Tweets containing ~p : ~p ~n",[HashTag,HashTagList]),
            profileHandler(ServerPID,HandlerPID,Username,SubscriberList,SelfTweetList,SubscribedTweetList);

        {search_mention,QueryKeyword}->
            %io:format("Timestamp ~p",os:timestamp()),
            Mention = string:sub_string(QueryKeyword, 2),
            ServerPID ! {getMention,self(),Mention},
            profileHandler(ServerPID,HandlerPID,Username,SubscriberList,SelfTweetList,SubscribedTweetList);

        {tweetByMention,Mention,MentionList}->
            %io:format("Timestamp ~p",os:timestamp()),
            io:format("Tweets containing @~p : ~p~n",[Mention,MentionList]),
            HandlerPID ! {searchResult,{mention,Mention,MentionList}},
            profileHandler(ServerPID,HandlerPID,Username,SubscriberList,SelfTweetList,SubscribedTweetList)

        
        % {search_subscribed,QueryKeyword}->
            
        
        end.

extractHashTag(TweetBody)->
    SplitTweet = string:split(TweetBody, " ", all),
    HashTagList = findSymbol(SplitTweet,length(SplitTweet),"#",[]),
    HashTagList.

extractMention(TweetBody)->
    SplitTweet = string:split(TweetBody, " ", all),
    MentionList = findSymbol(SplitTweet,length(SplitTweet),"@",[]),
    MentionList.

findSymbol(_SplitTweet,0,_Symbol,ResultList)->
    ResultList;
findSymbol(SplitTweet,Index,Symbol,ResultList)->
    
    Found = string:equal(Symbol, string:sub_string(lists:nth(Index,SplitTweet), 1, 1)),

    % ReturnList = case Found of
    %     true -> findSymbol(SplitTweet,Index-1,Symbol,ResultList++[string:sub_string(lists:nth(Index,SplitTweet), 2)]);
    %     false -> findSymbol(SplitTweet,Index-1,Symbol,ResultList)
    % end,

    ReturnList = if Found->
        findSymbol(SplitTweet,Index-1,Symbol,ResultList++[string:sub_string(lists:nth(Index,SplitTweet), 2)]);
    true->
        findSymbol(SplitTweet,Index-1,Symbol,ResultList)
    end,

    %io:format("ANISHA CHECK IF THE ABOVE WORKS"),

    % if Found->
    %     ReturnList = findSymbol(SplitTweet,Index-1,Symbol,ResultList++[string:sub_string(lists:nth(Index,SplitTweet), 2)]);
    % true->
    %     ReturnList = findSymbol(SplitTweet,Index-1,Symbol,ResultList)
    % end,

    ReturnList.