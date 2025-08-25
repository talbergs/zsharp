<?php

require_once __DIR__ . '/processor.php';

foreach (captures() as $capture) {
    $lines = explode(PHP_EOL, file_get_contents($capture->file));
    $line = $lines[$capture->startrow - 1];
    $leading_chars = substr($line, 0, $capture->startcol - 1);

    if (trim($leading_chars)) {
      Violation::formCapture($capture);
    }
}
