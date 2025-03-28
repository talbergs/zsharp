<?php declare(strict_types=1);

class Env
{
    public static function docs(): string
    {
        return getenv('DOCS') ?: '';
    }
}

class Capture
{
    public string $name;
    public string $text;
    public string $file;
    public int $startrow;
    public int $startcol;
    public int $endrow;
    public int $endcol;

    public function __construct(array $raw, string $file)
    {
        $this->name = $raw['name'];
        $this->text = $raw['text'];
        $this->file = $file;
        $this->startrow = $raw['start']['row'];
        $this->startcol = $raw['start']['column'];
        $this->endrow = $raw['end']['row'];
        $this->endcol = $raw['end']['column'];
    }
}

/**
 * @return Capture[]
 */
function captures(): array {
    static $result = null;

    if ($result !== null) {
        return $result;
    }
    
    $result = [];
    foreach (json_decode(file_get_contents('php://stdin'), true) as $capture) {
        foreach ($capture['matches'] as $match) {
            $result[] = new Capture($match, $capture['file']);
        }
    }

    return $result;
}

class Violation
{
    public static function formCapture(Capture $capture): void
    {
          echo json_encode([
              'docs' => Env::docs(),
              'file' => $capture->file,
              'line' => $capture->startrow
          ]) . PHP_EOL;
    }
}

// Default check.
if (basename($argv[0]) === 'processor.php') {
    array_map(Violation::formCapture(...), captures());
}

/*
EXAMPLE INPUT STRING
[
  {
    "file": "ui/map.php",
    "file_type": "php",
    "matches": [
      {
        "kind": "array_creation_expression",
        "name": "cap",
        "text": "array(\n1,2,3\n)",
        "start": {
          "row": 41,
          "column": 6
        },
        "end": {
          "row": 43,
          "column": 2
        }
      }
    ]
  }
]
*/
