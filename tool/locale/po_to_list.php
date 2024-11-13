<?php

$list = [];
$fh = fopen($argv[1], 'r');

$parse = fn (string $line, string $prefix) => json_decode(
  substr($line, strlen($prefix) + 1)
);

while ($line = fgets($fh)) {
  if (str_starts_with($line, 'msgid')) {
    $list[] = $parse($line, 'msgid');
  }
  elseif (str_starts_with($line, 'msgctxt')) {
    $list[] = $parse($line, 'msgctxt');
  }
}

echo serialize($list);
