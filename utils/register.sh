# A helper script to deploy a single stack to a specific server
# Usage: ./deploy.sh target_server stack_id

target=$1
shift
jobid=$1
shift
ansible-playbook jobs/$jobid/register.yml --extra-vars "target=$target" $@