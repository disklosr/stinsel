# A helper script to run system administration playbooks
# Usage: ./run.sh host_alias stack_id

target=$1
shift

playbookid=$1
shift

ansible-playbook \
    scripts/$playbookid*/run.yml \
    --extra-vars "target=$target" \
    $@