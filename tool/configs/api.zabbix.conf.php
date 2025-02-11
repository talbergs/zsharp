<?php

global $DB;

$DB['TYPE']       = ZBX_DB_POSTGRESQL;
$DB['SERVER']     = '127.0.0.1';
$DB['PORT']       = '{{ $PORT }}';
$DB['DATABASE']   = '{{ $DATABASE }}';
$DB['PASSWORD']   = null;
$DB['SCHEMA']     = null;
$DB['USER']       = '{{ $USER }}';
$DB['ENCRYPTION'] = false;
