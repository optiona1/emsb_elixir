#!/bin/sh

# 等待数据库就绪
while ! nc -z mysql 3306; do 
  sleep 1
done

# 执行数据库迁移
bin/emsb_elixir eval "EmsbElixir.Release.migrate()"

# 启动应用
exec bin/emsb_elixir "$@"
