#!/bin/bash
source /home/lubuntu/.rvm/scripts/rvm
source ENV

puma -C config/puma_prod.rb
