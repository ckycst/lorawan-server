%
% Copyright (c) 2016-2017 Petr Gotthard <petr.gotthard@centrum.cz>
% All rights reserved.
% Distributed under the terms of the MIT License. See the LICENSE file.
%

-type eui() :: <<_:64>>.
-type seckey() :: <<_:128>>.
-type devaddr() :: <<_:32>>.
-type frid() :: <<_:64>>.
-type intervals() :: [{integer(), integer()}].
-type adr_config() :: {integer(), integer(), intervals()}.
-type rxwin_config() :: {
    'undefined' | integer(),
    'undefined' | integer(),
    'undefined' | number()}.

-record(rxq, {
    freq :: number(),
    datr :: binary() | integer(),
    codr :: binary(),
    time :: calendar:datetime(),
    tmst :: integer(),
    rssi :: number(),
    lsnr :: number()}).

-record(txq, {
    region :: binary(),
    freq :: number(),
    datr :: binary() | integer(),
    codr :: binary(),
    tmst :: 'undefined' | integer(),
    time :: 'undefined' | 'immediately' | calendar:datetime(),
    powe :: 'undefined' | integer()}).

-record(user, {
    name :: nonempty_string(),
    pass :: string(),
    roles :: [string()]}).

-record(server, {
    name :: nonempty_string(),
    router_perf :: [{calendar:datetime(), integer(), integer()}]}).

-record(network, {
    name :: nonempty_string(),
    netid :: binary(), % network id
    subid :: 'undefined' | bitstring(), % sub-network id
    region :: binary(),
    max_eirp :: integer(),
    min_eirp :: integer(),
    tx_powe :: integer(),
    cflist :: 'undefined' | [integer()]}).

-record(gateway, {
    mac :: binary(),
    network :: nonempty_string(),
    group :: any(),
    tx_rfch :: integer(), % rf chain for downlinks
    ant_gain :: integer(), % antenna gain
    desc :: 'undefined' | string(),
    gpspos :: {number(), number()}, % {latitude, longitude}
    gpsalt :: 'undefined' | number(), % altitude
    ip_address :: {inet:ip_address(), inet:port_number(), integer()},
    last_alive :: 'undefined' | calendar:datetime(),
    last_report :: 'undefined' | calendar:datetime(),
    dwell :: [{calendar:datetime(), {number(), number(), number()}}], % {frequency, duration, hoursum}
    delays :: [{calendar:datetime(), {integer(), integer(), integer()}}]}). % {min, avg, max}

-record(multicast_channel, {
    devaddr :: devaddr(), % multicast address
    profiles :: [nonempty_string()],
    nwkskey :: seckey(),
    appskey :: seckey(),
    fcntdown :: integer()}). % last downlink fcnt

-record(profile, {
    name :: nonempty_string(),
    network :: nonempty_string(),
    app :: binary(),
    appargs :: any(),
    can_join :: boolean(),
    fcnt_check :: integer(),
    txwin :: integer(),
    adr_mode :: 0..2, % server requests
    adr_set :: adr_config(), % requested after join
    rxwin_set :: rxwin_config(), % requested
    request_devstat :: boolean()}).

-record(device, {
    deveui :: eui(),
    profile :: nonempty_string(),
    appargs :: any(), % application arguments
    appeui :: eui(),
    appkey :: seckey(),
    last_join :: calendar:datetime(),
    node :: devaddr()}).

-record(node, {
    devaddr :: devaddr(),
    profile :: nonempty_string(),
    appargs :: any(), % application arguments
    nwkskey :: seckey(),
    appskey :: seckey(),
    fcntup :: integer(), % last uplink fcnt
    fcntdown :: integer(), % last downlink fcnt
    first_reset :: calendar:datetime(),
    last_reset :: calendar:datetime(),
    reset_count :: integer(), % number of resets/joins
    last_rx :: 'undefined' | calendar:datetime(),
    gateways :: [{binary(), #rxq{}}], % last seen gateways
    adr_flag :: 0..1, % device supports
    adr_set :: adr_config(), % auto-calculated
    adr_use :: adr_config(), % used
    adr_failed=[] :: [atom()], % last request failed
    rxwin_use :: rxwin_config(), % used
    rxwin_failed=[] :: [atom()], % last request failed
    last_qs :: [{integer(), integer()}], % list of {RSSI, SNR} tuples
    average_qs :: 'undefined' | {number(), number()}, % average RSSI and SNR
    devstat_time :: 'undefined' | calendar:datetime(),
    devstat_fcnt :: 'undefined' | integer(),
    devstat :: [{calendar:datetime(), integer(), integer()}]}). % {time, battery, margin}

-record(ignored_node, {
    devaddr,
    mask}).

-record(connector, {
    connid,
    app,
    format,
    uri,
    published,
    subscribe,
    consumed,
    enabled,
    client_id,
    auth,
    name,
    pass,
    certfile,
    keyfile}).

-record(handler, {
    app,
    fields,
    parse,
    build}).

-record(rxdata, {
    fcnt :: integer(),
    port :: integer(),
    data :: binary(),
    shall_reply=false :: boolean()}).

-record(txdata, {
    confirmed=false :: boolean(),
    port :: 'undefined' | integer(),
    data :: 'undefined' | binary(),
    pending :: 'undefined' | boolean()}).

-record(pending, {
    devaddr :: devaddr(),
    confirmed :: boolean(),
    phypayload :: binary(),
    state :: any()}).

-record(txframe, {
    frid :: frid(), % unique identifier
    datetime :: calendar:datetime(),
    devaddr :: devaddr(),
    txdata :: #txdata{}}).

-record(rxframe, {
    frid :: frid(), % unique identifier
    app :: binary(),
    region :: binary(),
    devaddr :: devaddr(),
    gateways :: [{binary(), #rxq{}}], % singnal quality at each gateway
    average_qs :: 'undefined' | {number(), number()}, % average RSSI and SNR
    powe:: integer(),
    fcnt :: integer(),
    confirm :: boolean(),
    port :: integer(),
    data :: binary(),
    datetime :: calendar:datetime()}).

-record(event, {
    evid :: binary(),
    severity :: atom(),
    first_rx :: calendar:datetime(),
    last_rx :: calendar:datetime(),
    count :: integer(),
    entity :: atom(),
    eid :: binary(),
    text :: binary(),
    args :: 'undefined' | binary()}).

% end of file