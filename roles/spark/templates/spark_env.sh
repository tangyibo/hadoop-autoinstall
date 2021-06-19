export SPARK_DIST_CLASSPATH=$(hadoop classpath)
export SPARK_HOME={{ spark_path }}/spark-{{ spark_version }}-bin-without-hadoop
export PATH=$SPARK_HOME/bin:$PATH
export SPARK_MASTER_PORT={{ spark_master_port }}
export SPARK_MASTER_WEBUI_PORT={{ spark_web_port }}
