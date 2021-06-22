#!/bin/bash

helm install elk-master .  -n elk  -f master-values.yaml
helm install elk-data .  -n elk  -f data-node-values.yaml
helm install elk-ml .  -n elk  -f machine-learning-values.yaml
helm install elk-lb .  -n elk  -f coordinating-only-values.yaml