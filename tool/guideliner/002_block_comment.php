<?php

require_once __DIR__ . '/processor.php';

foreach (captures() as $capture) {
    $lines = explode(PHP_EOL, file_get_contents($capture->file));
    $empty_index = $capture->startrow - 2;

    if (array_key_exists($empty_index, $lines) && $lines[$empty_index] !== '') {
        Violation::formCapture($capture);
    }
}
