<?php

require_once __DIR__ . '/processor.php';

foreach (captures() as $capture) {
    if (preg_match('/^[A-Z]/', $capture->text)) {
        Violation::formCapture($capture);
    }
}
