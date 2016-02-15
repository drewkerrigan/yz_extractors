%% -------------------------------------------------------------------
%%
%% Copyright (c) 2012 Basho Technologies, Inc.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

-module(yz_deflate_json_extractor).
-compile(export_all).
-include("yokozuna.hrl").

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-spec extract(binary()) -> fields() | {error, any()}.
extract(Value) ->
    Decompressed = decompress(Value),
    yz_json_extractor:extract(Decompressed).

-spec extract(binary(), proplist()) -> fields() | {error, any()}.
extract(Value, Opts) ->
    Decompressed = decompress(Value),
    yz_json_extractor:extract(Decompressed, Opts).

decompress(Value) ->
    Z = zlib:open(),
    zlib:inflateInit(Z),
    Decompressed = zlib:inflate(Z, Value),
    zlib:inflateEnd(Z),
    zlib:close(Z),
    Decompressed.

compress(Value) ->
    Z = zlib:open(),
    ok = zlib:deflateInit(Z,default),
    Compressed = zlib:deflate(Z, Value, finish),
    ok = zlib:deflateEnd(Z),
    zlib:close(Z),
    Compressed.

%%%===================================================================
%%% Tests
%%%===================================================================

-ifdef(TEST).

compressed_json_test_() ->
{setup,
     fun() ->
             ok
     end,
     fun(_) ->
             ok
     end,
     [
      ?_test(begin
                 JsonProps = [{one, <<"one">>},{two, <<"two">>}],
                 JsonStr = mochijson2:encode(JsonProps),
                 JsonBin = list_to_binary(JsonStr),
                 Compressed = compress(JsonBin),
                 Expected = [{<<"two">>,<<"two">>},{<<"one">>,<<"one">>}],

                 ?assertEqual(Expected, extract(Compressed))
             end)]}.

-endif.
