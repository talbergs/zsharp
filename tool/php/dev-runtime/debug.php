<?php

require __DIR__.'/vendor/autoload.php';

use Symfony\Component\VarDumper\Cloner\VarCloner;
use Symfony\Component\VarDumper\Dumper\ServerDumper;
use Symfony\Component\VarDumper\VarDumper;

VarDumper::setHandler(function (mixed $var): ?string {
    $cloner = new VarCloner();
    $dumper = new ServerDumper('tcp://127.0.0.1:9912');

    return $dumper->dump($cloner->cloneVar($var));
});

function d() {
	dump(...func_get_args());
}

function dd() {
	dump(...func_get_args());
	die;
}

function trace() {
	$trace = [];
	foreach (debug_backtrace() as ['file' => $file, 'line' => $line]) {
		$trace[] = "$file:$line";
	}
	dump($trace);
}
