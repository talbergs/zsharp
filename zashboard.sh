export ZASHBOARD_PGDATA=$HOME/.cache/zashboard_pgdata
export ZASHBOARD_PGPORT=5432
export ZASHBOARD_UI_DIR=$HOME/MT/repos/zabbix

if [ ! -z "$1" ]; then
  echo "using config: $1"
  source "$1"
fi
