export SPARK_HOME={{ spark_path }}/spark-{{ spark_version }}
export PATH=$SPARK_HOME/bin:$PATH
export SPARK_MASTER_PORT={{ spark_master_port }}
export SPARK_MASTER_WEBUI_PORT={{ spark_web_port }}
