<?php

require_once __DIR__ . '/processor.php';

foreach (captures() as $capture) {
    if (preg_match('/^(public|protected|private)\s/', $capture->text) === 0) {
        Violation::formCapture($capture);
    }
}
