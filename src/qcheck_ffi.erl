-module(qcheck_ffi).

-export([fail/1, rescue_error/1]).

-spec fail(string()) -> no_return().
fail(String) ->
    erlang:error(String).

-spec rescue_error(fun()) -> {ok, any()} | {error, string()}.
rescue_error(F) ->
    try
        {ok, F()}
    catch
        error:String -> {error, String}
    end.
