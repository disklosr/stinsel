#!/bin/bash

docker ps -a --filter "label=stinsel.stack.id={{stack_id}}"