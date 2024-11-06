<?php

$conf = json_decode(file_get_contents($argv[1]), true);

$app = new App(
	new Conf(...$conf),
);

sleep(2);
$app->attachOwnLogs();

sleep(2);
$app->serveUi();

sleep(1);
$app->startDB();

sleep(2);
$app->startDBCli();

sleep(4);
$app->ensureDB();

sleep(4);
$app->ensureConfigFiles();

class Conf {
	public function __construct(
		public string $UI_ROOT,
		public string $UI_PORT,
		public string $DB_PORT,
		public string $DB_NAME,
		public string $DB_ROOT,
		public string $SOURCES,
		public string $SESSION,
	) {
	}
}

class App {
	private string $logfile;
	private string $runtime;
	public function __construct(
		public Conf $conf,
	) {
		$this->logfile = "/tmp/zashboard-{$this->conf->SESSION}.log";
		$this->runtime = "/tmp/zashboard-{$this->conf->SESSION}.run";
	}

	public function uiNewPane(string $options, string $command) {
		`zellij -s {$this->conf->SESSION} action new-pane {$options} -- {$command}`;
	}

	public function serveUi() {
		# TODO: ensure the locales is installed within php process
		# do not depend on OS.
		$this->log("Starting UI");
		$this->uiNewPane(
			options: "--name 'web:{$this->conf->UI_PORT}' --cwd '{$this->conf->UI_ROOT}'",
			command: "nix run github:talbergs/belt#run_php_dbg {$this->conf->UI_PORT}",
		);
	}

	public function startDB() {
		$this->log("Starting DB");
		$this->uiNewPane(
			options: "--name 'proc:postgres'",
			command: "nix-shell --run fg_postgres --argstr pgdata {$this->conf->DB_ROOT} --argstr dbport {$this->conf->DB_PORT} ./proc/postgres.nix",
		);
	}

	public function attachOwnLogs() {
		$this->uiNewPane(
			options: "--name '{$this->conf->SESSION}|logs'",
			command: "tail -F {$this->logfile}",
		);
	}

	public function log(string $message) {
		// TODO: send log to UI.
		file_put_contents('/tmp/ss', '['.date('Y-m-d H:i:s').'] '.$message.PHP_EOL, FILE_APPEND);
	}

	public function startDBCli() {
		$this->log("Starting DB CLI");
		$this->uiNewPane(
			options: "--name 'proc:postgres:cli'",
			command: "nix-shell --argstr dbport {$this->conf->DB_PORT} --argstr dbname {$this->conf->DB_NAME} ./proc/postgres-cli.nix",
		);
	}

	public function ensureDB() {
		$this->log("Ensure DB");
		$lines = `
			echo -n '\x\l' | nix-shell \
				--argstr dbport {$this->conf->DB_PORT} \
				./proc/postgres-cli.nix
		`;

		$has_db = false;
		foreach (explode(PHP_EOL, $lines) as $line) {
			if (preg_match('/^Name/', $line)) {
				[, $db_name] = array_map(trim(...), explode('|', $line));
				if ($db_name === $this->conf->DB_NAME) {
					$this->log("Found DB '{$this->conf->DB_NAME}'");
					$has_db = true;
					break;
				}
			}
		}

		if (!$has_db) {
			$this->log("No DB '{$this->conf->DB_NAME}' found.");
			$schema_dump = "/tmp/zash-db-schema-{$this->conf->DB_NAME}";
			if (!file_exists($schema_dump)) {
				$this->log("No DB schema file '$schema_dump' found.");
				$this->log("Building DB schema from sources in '{$this->conf->SOURCES}'.");
				// TODO: make it a floating instead.
				$this->uiNewPane(
					options: "--name 'building schema..' --cwd '{$this->conf->SOURCES}'",
					command: "nix run github:talbergs/belt#make_scheme {$this->runtime}/db",
				);
			}

			$this->log("Creating DB '{$this->conf->DB_NAME}'.");

			`
			echo -n "CREATE DATABASE {$this->conf->DB_NAME} ENCODING Unicode TEMPLATE template0;" \
				| nix-shell \
					--argstr dbport {$this->conf->DB_PORT} \
					./proc/postgres-cli.nix
			`;

			$this->log("Applying DB schema found in '$schema_dump'.");

			`
			cat "$schema_dump" | nix-shell \
					--argstr dbport {$this->conf->DB_PORT} \
					--argstr dbname {$this->conf->DB_NAME} \
					./proc/postgres-cli.nix
			`;

			$this->log("Done applying DB schema.");
		}
	}

	public function ensureConfigFiles() {
		$this->log("Ensuring config file.");
		$ui_conf = "{$this->conf->UI_ROOT}/conf/zabbix.conf.php";
		if (!file_exists($ui_conf)) {
			$this->log("No UI config file '$ui_conf' found, creating new one.");
			file_put_contents($ui_conf, implode(PHP_EOL, [
				"<?php",
				"\$DB['TYPE'] = ZBX_DB_POSTGRESQL;",
				"\$DB['SERVER']	= 'localhost';",
				"\$DB['PORT'] = '{$this->conf->DB_PORT}';",
				"\$DB['DATABASE'] = '{$this->conf->DB_NAME}';",
				"\$DB['USER'] = 'mt';", # `whoami`
				"\$DB['PASSWORD'] = '';",
			]));
		}
		// todo
	}
}
