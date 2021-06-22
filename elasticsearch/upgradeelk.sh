#!/bin/bash

helm upgrade elk-master .  -n elk  -f master-values.yaml
helm upgrade elk-data .  -n elk  -f data-node-values.yaml
helm upgrade elk-ml .  -n elk  -f machine-learning-values.yaml
helm upgrade elk-lb .  -n elk  -f coordinating-only-values.yaml

