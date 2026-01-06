-module(qcheck_ffi).

-export([rescue_error/1]).

-spec rescue_error(fun()) -> {ok, any()} | {error, string()}.
rescue_error(F) ->
    try
        {ok, F()}
    catch
        error:#{message := Message} ->
            {error, Message}
    end.
