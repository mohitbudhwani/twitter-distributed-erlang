-module(twitterserver).
-export([start_server/0,server/3]).

start_server()->
    ServerPid = spawn_link(twitterserver,server,[maps:new(),maps:new(),maps:new()]),
    ServerPid.

server(UserListMap,HashTagMap,MentionMap)->
    receive
        {newUser,Username,Pid}->
            UserBufferMap = maps:put(Username,Pid,UserListMap),
            server(UserBufferMap,HashTagMap,MentionMap);

        % {subscribe, User1, User2}->
        %     maps:get(User2,UserListMap) ! {addSubscriber,User1},
        %     server(UserListMap,HashTagMap,MentionMap);

        {getUserPIDforSubscribtion,User1,User2} ->
            UserID2 = maps:get(User2, UserListMap),
            User1 ! {subscribtionPID,UserID2},
            server(UserListMap,HashTagMap,MentionMap);
        
        {tweet,Username,SubscriberList,Tweet}->
            io:format("\nDEBUG : SENDING TWEETS FROM ~p to ~p",[Username,SubscriberList]),
            lists:foreach(fun(P)-> maps:get(P,UserListMap) ! {newTweetFeed,Username,Tweet} end , SubscriberList),
            server(UserListMap,HashTagMap,MentionMap);
           
        {hashtag,Username,Tweet,HashTag} ->
            HashTagList = maps:get(HashTag,HashTagMap,[]),
            NewHashTagList = [{Username,Tweet}]++HashTagList,
            HashTagMapBuffer = maps:put(HashTag,NewHashTagList,HashTagMap),
            server(UserListMap,HashTagMapBuffer,MentionMap);

        {getHashTag,UserPID,HashTag} ->
            io:format("server step 2/3"),
            HashTagList = maps:get(HashTag,HashTagMap,[]),
            UserPID ! {tweetByHashtag,HashTag,HashTagList},
            server(UserListMap,HashTagMap,MentionMap);

        

        {mention,Username,Tweet,Mention} ->
            MentionList = maps:get(Mention,MentionMap,[]),
            NewMentionList = [{Username,Tweet}]++MentionList,
            MentionMapBuffer = maps:put(Mention,NewMentionList,MentionMap),
            server(UserListMap,HashTagMap,MentionMapBuffer);

        {getMention,UserPID,Mention} ->
            MentionList = maps:get(Mention,MentionMap,[]),
            UserPID ! {tweetByMention,Mention,MentionList},
            server(UserListMap,HashTagMap,MentionMap);


        {getUserListMap,Simulator}->
            %io:format("received request~n"),
            Simulator ! {userMap,UserListMap},
            server(UserListMap,HashTagMap,MentionMap)

end.


 