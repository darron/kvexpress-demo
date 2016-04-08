#!/bin/bash

consul-cli kv write kvexpresshosts/services/bubs 1
consul-cli kv write kvexpresshosts/services/bunk 1
consul-cli kv write kvexpresshosts/services/cassandra 1
consul-cli kv write kvexpresshosts/services/consul 1
consul-cli kv write kvexpresshosts/services/context-server 1
consul-cli kv write kvexpresshosts/services/daniels 1
consul-cli kv write kvexpresshosts/services/delancie 1
consul-cli kv write kvexpresshosts/services/druid 1
consul-cli kv write kvexpresshosts/services/haproxy 1
consul-cli kv write kvexpresshosts/services/influx 1
consul-cli kv write kvexpresshosts/services/kafka 1
consul-cli kv write kvexpresshosts/services/lamar 1
consul-cli kv write kvexpresshosts/services/mysql 1
consul-cli kv write kvexpresshosts/services/postgresql 1
consul-cli kv write kvexpresshosts/services/prometheus 1
consul-cli kv write kvexpresshosts/services/rawls 1
consul-cli kv write kvexpresshosts/services/redis 1
consul-cli kv write kvexpresshosts/services/spark 1
consul-cli kv write kvexpresshosts/services/spidly 1
consul-cli kv write kvexpresshosts/services/tick 1
consul-cli kv write kvexpresshosts/services/trace 1

sudo service kvexpresshosts start
