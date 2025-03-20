<?php

require_once __DIR__ . '/processor.php';

foreach (captures() as $capture) {
    if ($capture->text[1] !== PHP_EOL) {
        Violation::formCapture($capture);
    }
}
