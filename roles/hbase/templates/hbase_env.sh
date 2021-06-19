export HBASE_HOME={{ hbase_path }}/hbase-{{hbase_version}}
export PATH=$HBASE_HOME/bin:$PATH
export HBASE_MANAGES_ZK=false
export HBASE_LOG_DIR={{ hbase_log_path }}
