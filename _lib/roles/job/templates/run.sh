#!/bin/bash

{{job_base_dir}}/scripts/job.sh \
    && curl -fsS -m 10 --retry 5 \
    https://status.{{admin_host}}/ping/{{job_token}}