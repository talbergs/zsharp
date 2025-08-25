<?php

define('PHPUNIT_URL', '{{ $PHPUNIT_URL }}');
define('PHPUNIT_LOGIN_NAME', 'Admin');
define('PHPUNIT_LOGIN_PWD', 'zabbix');
define('PHPUNIT_BASEDIR', '{{ $PHPUNIT_BASEDIR }}');
define('PHPUNIT_SCREENSHOT_DIR', '{{ $PHPUNIT_SCREENSHOT_DIR }}');
define('PHPUNIT_SCREENSHOT_URL', '{{ $PHPUNIT_SCREENSHOT_URL }}');
define('PHPUNIT_REFERENCE_DIR', '{{ $PHPUNIT_REFERENCE_DIR }}');

define('PHPUNIT_BINARY_DIR', '/sbin/');
define('PHPUNIT_CONFIG_SOURCE_DIR', '/conf/');
define('PHPUNIT_CONFIG_DIR', '/etc/');
define('PHPUNIT_COMPONENT_DIR', '{{ $PHPUNIT_COMPONENT_DIR }}');
define('PHPUNIT_DRIVER_ADDRESS', '127.0.0.1');
define('PHPUNIT_BROWSER_NAME', 'chrome');
define('PHPUNIT_DATA_DIR', '{{ $PHPUNIT_DATA_DIR }}');
define('PHPUNIT_DATA_SOURCES_DIR', '{{ $PHPUNIT_DATA_SOURCES_DIR }}');

if (!defined('PHPUNIT_ERROR_LOG')) {
	define('PHPUNIT_ERROR_LOG', '{{ $PHPUNIT_ERROR_LOG }}/errors.txt');
}

define('PHPUNIT_PORT_PREFIX', '100');
define('PHPUNIT_LDAP_HOST', 'qa-ldap.zabbix.sandbox');
define('PHPUNIT_LDAP_BIND_PASSWORD', 'zabbix#33');
define('PHPUNIT_LDAP_USERNAME', 'user1');
define('PHPUNIT_LDAP_USER_PASSWORD', 'zabbix#33');
